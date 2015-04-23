class PrintController < ApplicationController
    layout false

    def tracking
        @order = Order.find(params[:id])
    end

    def trackingnum
        order = Order.find(params[:id])
        order.tracking_number=params[:num]
        order.status='printed'
        order.user_id=current_user.id
        order.save
        flash[:alert] = "正在打印"
    end

    def keytracking
        @keyclientorder = Keyclientorder.find(params[:id])
    end

    def keytrackingnum
        @transport_type=params[:transport_type]
        start=params[:start].to_i
        ending=params[:end].to_i
        @keyclientorder = Keyclientorder.find(params[:id])
        @orders=@keyclientorder.orders.order("customer_postcode").limit(ending-start+1)
        @orders.each_with_index do |order,i|
            order.tracking_number=(start+i).to_s
            order.status='printed'
            order.user_id=current_user.id
            order.transport_type=@transport_type
            order.save
        end
        flash[:alert] = "正在打印"
    end

    def webprint
        @ids=params[:ids]
        @flag=params[:flag]
    end

    def webtracking
        @ids=params[:ids]
        @flag=params[:flag]
    end

    def webhottracking
        # binding.pry
        @ids=params[:ids]
        @flag=params[:flag]
        @logistics = Logistic.where(storage_id: current_storage.id).order(is_default: :desc)
    end

    def webtrackingnum
        @keycorder =nil
        if params[:flag]=='filter'
            time = Time.new
            # batch_no = time.year.to_s+time.month.to_s.rjust(2,'0')+time.day.to_s.rjust(2,'0')+Keyclientorder.count.to_s.rjust(5,'0')
            @keycorder = Keyclientorder.create(keyclient_name: "auto",unit_id: current_user.unit_id,storage_id: current_storage.id,user: current_user,status: "printed")
        end
        @transport_type=params[:transport_type]
        #regular = /([\D]*)([\d]*)/
        start=getTrackingNumber(@transport_type, params[:start])
        numberSize = start[1].size
        ending=getTrackingNumber(@transport_type, params[:end])
        @ids=params[:id].split(",").map(&:to_i)
        (start[1].to_i..ending[1].to_i).each_with_index do |num,i|
            #puts "----------" << i.to_s << "---------"
            #puts "num=" << num.to_s
            order = Order.find(@ids[i])
            num_s = sprintf("%0#{numberSize.to_s}d", num)
            #puts "numberSize=" << numberSize.to_s
            #puts "num_s=" << num_s.to_s
            #puts "start[0]=" << start[0].to_s
            #puts "start[1]=" << start[1].to_s
            #puts "start[2]=" << start[2].to_s
            case num_s.size
            when 8
                order.tracking_number=start[0] + num_s + checkTrackingNO(num_s).to_s + start[2]
            when 11
                order.tracking_number=start[0] + num_s
            end
            #puts "order.tracking_number=" << order.tracking_number
            order.status='printed'
            order.user_id=current_user.id
            order.transport_type=@transport_type
            if params[:flag]=='filter'
                order.keyclientorder_id=@keycorder.id
            end
            #puts order.tracking_number
            order.save
        end
        # flash[:alert] = "正在打印"

        # format.html { redirect_to keyclientorder_orders_path(@keycorder), notice: '正在打印' }
        # format.json { head :no_content }
    end

    def webhottrackingnum
        @keycorder =nil
        if params[:flag]=='filter'
            time = Time.new
            # batch_no = time.year.to_s+time.month.to_s.rjust(2,'0')+time.day.to_s.rjust(2,'0')+Keyclientorder.count.to_s.rjust(5,'0')
            @keycorder = Keyclientorder.create(keyclient_name: "auto",unit_id: current_user.unit_id,storage_id: current_storage.id,user: current_user,status: "printed")
        end
        @logistic = Logistic.find(params[:transport_type])
        @transport_type=@logistic.print_format
        numberSize = params[:mlnum].to_i
        @ids=params[:id].split(",").map(&:to_i)

        rq=@logistic.getMailNum('信息局',@logistic.param_val1,@logistic.param_val2,numberSize)
        if !rq.nil?
            rqback=rq.split(':')
            if rqback[0] == "SUCCESS"
                rqbody = rqback[1].split("|")
                seqno = rqbody[0]
                numstart = rqbody[1]
                numend = rqbody[2]
                numary = getHotTrackingNumber(@transport_type,numstart,numberSize)
                @ids.each_with_index do |num,i|
                    @order=Order.find(num)
                    @order.update(tracking_number: numary[i])
                end
            else
                url = "/print/webtracking?flag="+params[:flag]+"&&ids="+params[:id]
                flash[:error]="取号段失败"+rqback[1]
                redirect_to url
            end
        end
    end

    def getTrackingNumber(transport_type, tracking_number)
        return_no = []
        case transport_type
        when "tcsd"
            case tracking_number.size
            when 13
                return_no << tracking_number[0,2] << tracking_number[2,8] << tracking_number[11,2]
            when 10
                return_no << tracking_number[0,2] << tracking_number[2,8] << "31"
            when 8
                return_no << "PN" << tracking_number << "31"
            end
        when "gnxb"
            case tracking_number.size
            when 13
                return_no << tracking_number[0,2] << tracking_number[2,11] << ""
            end
        when "ems"
            case tracking_number.size
            when 13
                return_no << tracking_number[0,2] << tracking_number[2,8] << tracking_number[11,2]
            when 10
                return_no << tracking_number[0,2] << tracking_number[2,8] << "06"
            when 8
                return_no << "10" << tracking_number << "06"
            end
        end
        return return_no    
    end

    def getHotTrackingNumber(transport_type, tracking_number, num_count)
        return_no = []
        case transport_type
        when "tcsd"
            if num_count == 1
                return_no << tracking_number
            elsif num_count > 1
                return_no << tracking_number
                (2..num_count).each_with_index do |num,i|
                    tracking_number = calNextTrackingNo(tracking_number)
                    return_no << tracking_number 
                end
            end
        end
        return return_no    
    end

    def calNextTrackingNo(tracking_number)
        rt_num = ""
        tmpnum = tracking_number[1,8]
        chknum = checkTrackingNO((tmpnum.to_i+1).to_s)
        rt_num = tracking_number[0,2]+(tracking_number[1,8].to_i+1).to_s+chknum+tracking_number[11,2]
        return rt_num
    end

    def checkTrackingNO(num)
        x = [8,6,4,2,3,5,9,7]
        num_a = num.split("")
        sum = 0
        num_a.each_with_index do |s,i|
            sum = sum + s.to_i* x[i]
        end
        r = sum % 11
        case r
        when 0
            return "5"
        when 1
            return "0"
        else
            return (11 - r).to_s
        end
    end

    def websplitordertracking
        @order = Order.find(params[:orid])
        @logistics = Logistic.where(storage_id: current_storage.id).order(is_default: :desc)
    end

    def websplitordertrackingnum
        @order = Order.find(params[:orid])
        @logistic = Logistic.find(params[:transport_type])
        @transport_type = @logistic.print_format
        @order.update(transport_type: @transport_type)        
    end

    def shelfbarcodeprint
        @shelf = Shelf.find(params[:sid])
    end

    def areabarcodeprint
        @shelves = Area.find(params[:sid]).shelves
    end

    def relationbarcodeprint
        @relationship = Relationship.find(params[:rid])
    end

end
