class LogisticsController < ApplicationController
  load_and_authorize_resource :logistic

  def index
    @logistics_grid = initialize_grid(@logistics)
  end

  def show
    # respond_with(@logistic)
  end

  def new
    # @logistic = Logistic.new
    # respond_with(@logistic)
  end

  def edit
  end

  def create
    respond_to do |format|
      if @logistic.save
        format.html { redirect_to @logistic, notice: I18n.t('controller.create_success_notice', model: '物流')}
        format.json { render action: 'show', status: :created, location: @logistic }
      else
        format.html { render action: 'new' }
        format.json { render json: @logistic.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @logistic.update(logistic_params)
        format.html { redirect_to @logistic, notice: I18n.t('controller.update_success_notice', model: '物流') }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @logistic.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @logistic.destroy
    respond_to do |format|
      format.html { redirect_to logistics_url }
      format.json { head :no_content }
    end
  end

  def hotprint_ready
    @ids=params[:ids]
    @flag=params[:flag]
    @oid=@ids.split(",").map(&:to_i)[0]
    @order=Order.find(@oid)
    if @order.transport_type=="gjxbp" || @order.transport_type=="gjxbg"
      @logistic=Logistic.where(print_format: @order.transport_type).first
    end
    @logistics = Logistic.all.order(is_default: :desc)
    render :layout => false
  end

  def hotprint_show
        @keycorder =nil
        if params[:flag]=='filter'
            time = Time.new
            # batch_no = time.year.to_s+time.month.to_s.rjust(2,'0')+time.day.to_s.rjust(2,'0')+Keyclientorder.count.to_s.rjust(5,'0')
            @keycorder = Keyclientorder.create(keyclient_name: "auto",unit_id: current_user.unit_id,storage_id: current_storage.id,user: current_user,status: "printed")
        end
        @logistic = Logistic.find(params[:transport_type])
        @transport_type=@logistic.print_format
        @ids=params[:oid].split(",").map(&:to_i)
        numberSize = @ids.size

        # numary=@logistic.getMailNum(numberSize,current_storage)
        # if !numary.nil?
        #   @ids.each_with_index do |num,i|
        #     @order=Order.find(num)
        #     @order.transport_type=@logistic.print_format
        #     @order.tracking_number=numary[i]
        #     @order.status='printed'
        #     if params[:flag]=='filter'
        #         @order.keyclientorder_id=@keycorder.id
        #     end
        #     @order.save
        #   end
        # end
        # rq=@logistic.getMailNum('信息局',@logistic.param_val1,@logistic.param_val2,numberSize)
        # if !rq.nil?
        #     rqback=rq.split(':')
        #     if rqback[0] == "SUCCESS"
        #         rqbody = rqback[1].split("|")
        #         seqno = rqbody[0]
        #         numstart = rqbody[1]
        #         numend = rqbody[2]
        #         numary = getHotTrackingNumber(@transport_type,numstart,numberSize)
        #         @ids.each_with_index do |num,i|
        #             @order=Order.find(num)
        #             @order.update(tracking_number: numary[i])
        #             @order.update(status: 'printed')
        #         end
        #     else
        #         # url = "/print/webtracking?flag="+params[:flag]+"&&ids="+params[:id]
        #         flash[:error]="取号段失败"+rqback[1]
        #         redirect_to :action => "webprint",:flag => params[:flag],:ids => params[:id]
        #     end
        # end
    render :layout => false
  end

  private
    def set_logistic
      @logistic = Logistic.find(params[:id])
    end

    def logistic_params
      params.require(:logistic).permit(:name, :wl_no, :print_format, :is_getnum, :contact, :address, :contact_phone, :post, :is_default, :param_val1, :param_val2)
    end
end
