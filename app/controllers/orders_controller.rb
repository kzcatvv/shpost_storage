class OrdersController < ApplicationController
  load_and_authorize_resource

  user_logs_filter only: [:ordercheck], symbol: :batch_no, operation: '确认出库', object: :keyclientorder
  # GET /orderes
  # GET /orderes.json
  def index
    @orders_grid = initialize_grid(@orders,
                   :conditions => {:order_type => "b2c"})
  end

  def order_alert
    @orders = Order.where( [ "status = ? and storage_id = ? and created_at < ?", 'waiting',session[:current_storage].id, Time.now-Business.find(StorageConfig.config["business"]['jh_id']).alertday.day])
    @orders_grid = initialize_grid(@orders)
  end

  # GET /orderes/1
  # GET /orderes/1.json
  def show
  end

  # GET /orderes/new
  def new

    # @order.order_type = Order::TYPE[:pubiicclient]

   # @order = Order.new

  end

  # GET /orderes/1/edit
  def edit
  end

  # POST /orderes
  # POST /orderes.json
  def create

   # @order = Order.new(order_params)
   # @order.order_type = "pubiicclient"
   # @order.unit_id = current_user.unit_id
#@order.storage_id = current_storage.id 

    @order = Order.new(order_params)
   

    @order.order_type = Order::TYPE[:b2c]
    @order.status = Order::STATUS[:waiting]
    @order.unit = current_user.unit
    @order.storage = current_storage
   # @order.no = Time.now.to_s.split(':').first

    respond_to do |format|
      if @order.save
        format.html { redirect_to @order, notice: 'Order was successfully created.' }
        format.json { render action: 'show', status: :created, location: @order }
      else
        format.html { render action: 'new' }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orderes/1
  # PATCH/PUT /orderes/1.json
  def update
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to @order, notice: 'Order was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orderes/1
  # DELETE /orderes/1.json
  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to orders_url }
      format.json { head :no_content }
    end
  end

  def findprint
   @orders = Order.where("order_type = 'b2c' and keyclientorder_id is not null").joins("LEFT JOIN keyclientorders ON orders.keyclientorder_id = keyclientorders.id").where("keyclientorders.user_id = ? and keyclientorders.status='waiting'", current_user)
   if @orders.empty?

    @orders = Order.where(" order_type = ? and status = ? ","b2c","waiting").joins("LEFT JOIN order_details ON order_details.order_id = orders.id").order("order_details.specification_id")
    find_has_stock(@orders, true)
    
   else
    @keycorder=Keyclientorder.where(keyclient_name: "auto",user: current_user,status: "waiting").order('batch_no').first
    @orders=@keycorder.orders
    #find_has_stock(@orders)
   end

  end

  def find_has_stock(orders,createKeyCilentOrderFlg)
    allcnt = {}
    findorders = []
    ordercnt = 0
    orders.each do |o|
      hasstockchk = true
      #if ordercnt < 25
      o.order_details.each do |d|
        product = [o.business_id,d.specification_id,d.supplier_id]
        Rails.logger.info "business:" + o.business_id.to_s
        Rails.logger.info "specification:" + d.specification_id.to_s
        Rails.logger.info "supplier:" + d.supplier_id.to_s
        Rails.logger.info "storage:" + current_storage.id.to_s
        allamount = Stock.total_stock_in_storage(d.specification, d.supplier, o.business, current_storage)
        Rails.logger.info "allamount:" + allamount.to_s
        if allcnt.has_key?(product)
          if allcnt[product][0]-allcnt[product][1]-d.amount >= 0
            allcnt[product][1]=allcnt[product][1]+d.amount
            dtlchk=true
          else
            allcnt[product][1]=allcnt[product][1]+d.amount
            dtlchk=false
          end
        else
          if allamount - d.amount >= 0
            allcnt[product]=[allamount,d.amount]
            dtlchk=true
          else
            allcnt[product]=[allamount,d.amount]
            dtlchk=false
          end
        end
        hasstockchk=hasstockchk && dtlchk
      end

      if hasstockchk
        findorders += Order.where(id: o)
        ordercnt += 1
      else
        o.order_details.each do |dtl|
          product = [o.business_id,dtl.specification_id,dtl.supplier_id]
          allcnt[product][1]=allcnt[product][1]-dtl.amount
        end
      end
      Rails.logger.info "all product info: " + allcnt.to_s
     #end
    end
    
    if createKeyCilentOrderFlg
    if ordercnt > 0
      time = Time.new
      # batch_no = time.year.to_s+time.month.to_s.rjust(2,'0')+time.day.to_s.rjust(2,'0')+Keyclientorder.count.to_s.rjust(5,'0')
      @keycorder = Keyclientorder.create(keyclient_name: "auto",unit_id: current_user.unit_id,storage_id: session[:current_storage].id,user: current_user,status: "waiting")
      orders=Order.where(id: findorders)
      orders.update_all(keyclientorder_id: @keycorder)

      allcnt.each do |k,v|
         if v[1] > 0
          Keyclientorderdetail.create(keyclientorder: @keycorder,business_id: k[0],specification_id: k[1],supplier_id: k[2],amount: v[1])
         end
      end
    end
    end

    orders=Order.where(id: findorders)

  end

  def nextbatch
    @keycorder=params[:format]
    @keyclientorder=Keyclientorder.find(params[:format])
    @keyclientorder.update_attribute(:status,"checked")
    redirect_to :action => 'findprint'
  end

  def stockout
    Stock.transaction do
      begin
   if !params[:keyclientorder_id].nil?
       sklogs=[]
       # chkout=0
       has_out=0
       @keycorder=params[:keyclientorder_id]
       keyorder=Keyclientorder.find(params[:keyclientorder_id])
       @orders = keyorder.orders
       @stock_logs = StockLog.where(keyclientorderdetail_id: keyorder.keyclientorderdetails)
       if !@stock_logs.blank?
        @stock_logs_grid = initialize_grid(@stock_logs)
        return @stock_logs_grid
       end

       if key_check_out_stocks(keyorder)
          keyordercnt = keyorder.orders.count
          keyorder.orders.each do |od|
            od.update_attribute(:is_shortage,"no")
          end

       else
          keyordercnt = get_has_cnt(keyorder)

          if keyorder.stock_logs.distinct.empty?
            keyorder.orders.limit(keyordercnt).each do |order|
              order.update_attribute(:is_shortage,"no")
            end

            keyorder.orders.offset(keyordercnt).each do |o|
              o.update_attribute(:is_shortage,"yes")
            end
          else
            keyorder.orders.where(is_shortage: "yes").limit(keyordercnt).each do |order|
              order.update_attribute(:is_shortage,"no")
            end

            keyorder.orders.where(is_shortage: "yes").offset(keyordercnt).each do |o|
              o.update_attribute(:is_shortage,"yes")
            end
          end
       end
       chkout=keyorder.orders.where(is_shortage: "yes").count
   
       if keyordercnt > 0
        keyorder.keyclientorderdetails.each do |keydtl|
         if keydtl.amount > 0
            outstocks = Stock.find_stocks_in_storage(keydtl.specification, keydtl.supplier, keyorder.business, current_storage).to_ary
             outbl = false
             amount = keydtl.amount * keyordercnt
             sls=keyorder.stock_logs.where(stock_id: outstocks.to_ary).distinct
             sls.each do |sl|
              has_out += sl.amount
             end
             koallcnt=keydtl.amount*keyorder.orders.count
             offsetcnt=has_out
             lastamount=0
             
              if koallcnt - has_out > 0
                outstocks.each do |outstock|
                 if outstock.virtual_amount > 0
                  if !outbl
                    if outstock.virtual_amount - amount >= 0
                     setamount = outstock.virtual_amount - amount
                     outbl = true
                     outstock.update_attribute(:virtual_amount , setamount)
                     outstock.save
                     stklog = StockLog.create(stock: outstock, user: current_user, operation: StockLog::OPERATION[:b2b_stock_out], status: StockLog::STATUS[:waiting], amount: amount, operation_type: StockLog::OPERATION_TYPE[:out], keyclientorderdetail_id: keydtl.id)
                     #sklogs += StockLog.where(id: stklog)
                     ods=keyorder.order_details.where(specification_id: keydtl.specification_id,supplier_id: keydtl.supplier_id).offset(offsetcnt/keydtl.amount).limit((lastamount+amount)/keydtl.amount)
                     stklog.order_details << ods
                    else 
                     amount = amount - outstock.virtual_amount
                     getamount = outstock.virtual_amount
                     outbl = false
                     stklog = StockLog.create(stock: outstock, user: current_user, operation: StockLog::OPERATION[:b2b_stock_out], status: StockLog::STATUS[:waiting], amount: outstock.virtual_amount, operation_type: StockLog::OPERATION_TYPE[:out], keyclientorderdetail_id: keydtl.id)
                     #sklogs += StockLog.where(id: stklog)
                     if amount + outstock.virtual_amount == keydtl.amount * keyordercnt
                      if getamount/keydtl.amount == 0
                        ods = keyorder.order_details.where(specification_id: keydtl.specification_id,supplier_id: keydtl.supplier_id).offset(has_out/keydtl.amount).limit(1)
                        lastamount=getamount
                      else
                        lastamount=getamount%keydtl.amount
                        if lastamount == 0 
                          ods = keyorder.order_details.where(specification_id: keydtl.specification_id,supplier_id: keydtl.supplier_id).offset(has_out/keydtl.amount).limit(getamount/keydtl.amount)
                        else
                          ods = keyorder.order_details.where(specification_id: keydtl.specification_id,supplier_id: keydtl.supplier_id).offset(has_out/keydtl.amount).limit(getamount/keydtl.amount+1)
                        end
                      end
                      offsetcnt += getamount
                     else
                      if (lastamount+getamount)/keydtl.amount == 0
                        ods = keyorder.order_details.where(specification_id: keydtl.specification_id,supplier_id: keydtl.supplier_id).offset(offsetcnt/keydtl.amount).limit(1)
                        lastamount=lastamount+getamount
                      else
                        lastamount = (lastamount + getamount)%keydtl.amount
                        if lastamount == 0
                          ods = keyorder.order_details.where(specification_id: keydtl.specification_id,supplier_id: keydtl.supplier_id).offset(offsetcnt/keydtl.amount).limit((lastamount+getamount)/keydtl.amount)
                        else
                          ods = keyorder.order_details.where(specification_id: keydtl.specification_id,supplier_id: keydtl.supplier_id).offset(offsetcnt/keydtl.amount).limit((lastamount+getamount)/keydtl.amount + 1)
                        end
                      end
                      offsetcnt += getamount
                     end
                     stklog.order_details << ods
                     outstock.update_attribute(:virtual_amount , 0)
                     outstock.save
                    end
                  end
                 end
                end
              end
          end

        end
       end
       # sklogs=StockLog.where(id: keyorder.stock_logs)
       # details = keyorder.keyclientorderdetails
       # ids = []
       # details.each do |detail|
       #   ids << detail.id
       # end
       @stock_logs = StockLog.where(keyclientorderdetail_id: keyorder.keyclientorderdetails)
       # puts @stock_logs.size
      #binding.pry
      @stock_logs_grid = initialize_grid(@stock_logs)

   else
    product_hash = {}
    sklogs=[]
    chkout=0
    @keycorder=params[:format]
    @keyclientorder=Keyclientorder.find(params[:format])
    @orders=@keyclientorder.orders

    @orders.each do |order|

      if Stock.check_out_stocks(order, order.order_details, current_storage)
        order.order_details.each do |detail|
          product_hash = Stock.get_product_hash(order,detail,product_hash)
          # product = [order.business,orderdtl.specification,orderdtl.supplier]
          # if allcnt.has_key?(product)
          #     allcnt[product][0]=allcnt[product][0]+orderdtl.amount
          #     allcnt[product][1]<<orderdtl
          # else
          #     allcnt[product]=[orderdtl.amount, [orderdtl]]
          # end
        end
        order.update_attribute(:is_shortage,"no")
        order.set_picking
      else
        order.update_attribute(:is_shortage,"yes")
      end
    end
    # puts allcnt

    sklogs = Stock.stock_out(product_hash, current_storage, current_user)

    # product_hash.each do |x|
    #   product = x[0]
    #   amount = x[1][0]
    #   details = x[1][1]
    #   # puts "-------product info--------"
    #   # puts product
    #   # puts "-------amount info--------"
    #   # puts amount
    #   if details.first.stock_logs.blank?
    #     outstocks = Stock.find_stocks_in_storage(product[1], product[2], product[0], current_storage).to_ary
    #     # puts "-------outstocks size--------"
    #     # puts outstocks.size
    #     outstocks.each do |outstock|
    #       # puts "-------------outstock----------------"
    #       # puts "-----------outstock info-------------"
    #       # puts outstock.id
    #       available_amount = outstock.get_available_amount
    #       # puts "----------available amount-----------"
    #       # puts available_amount
    #       if available_amount == 0
    #         next
    #       elsif available_amount >= amount
    #         outstock.update_attribute(:virtual_amount , outstock.virtual_amount - amount)
    #         outstock.save
    #         stocklog = StockLog.create(stock: outstock, user: current_user, operation: StockLog::OPERATION[:b2c_stock_out], status: StockLog::STATUS[:waiting], amount: amount, operation_type: StockLog::OPERATION_TYPE[:out])
    #         details.each do |x|
    #           x.stock_logs << stocklog
    #         end
    #         sklogs << stocklog
    #         break
    #       else
    #         amount = amount - available_amount
    #         outstock.update_attribute(:virtual_amount , outstock.virtual_amount - available_amount)
    #         outstock.save
    #         stocklog = StockLog.create(stock: outstock, user: current_user, operation: StockLog::OPERATION[:b2c_stock_out], status: StockLog::STATUS[:waiting], amount: available_amount, operation_type: StockLog::OPERATION_TYPE[:out])
    #         details.each do |x|
    #           x.stock_logs << stocklog
    #         end
    #         sklogs << stocklog
    #       end
    #     end
    #   else
    #     sklogs += details.first.stock_logs
    #   end
    # end

    # puts sklogs
    # puts "-----------------------end------------------------"

   #        if orderdtl.amount > 0
   #          outstocks = Stock.find_stocks_in_storage(orderdtl.specification, orderdtl.supplier, order.business, current_storage).to_ary
   #          outbl = false
   #          amount = orderdtl.amount

   #            if orderdtl.amount - orderdtl.stock_logs.sum(:amount) > 0
   #              amount = orderdtl.amount - orderdtl.stock_logs.sum(:amount) 
   #               outstocks.each do |outstock|
   #                 if outstock.virtual_amount > 0
   #                  if !outbl
   #                    if outstock.virtual_amount - amount >= 0
   #                     setamount = outstock.virtual_amount - amount
   #                     outbl = true
   #                     outstock.update_attribute(:virtual_amount , setamount)
   #                     outstock.save
   #                     #keyorderdtl=@keyclientorder.keyclientorderdetails.where(business_id: order.business_id,specification_id: orderdtl.specification_id,supplier_id: orderdtl.supplier_id).first
   #                     stklog = StockLog.create(stock: outstock, user: current_user, operation: StockLog::OPERATION[:b2c_stock_out], status: StockLog::STATUS[:waiting], amount: amount, operation_type: StockLog::OPERATION_TYPE[:out])
   #                     orderdtl.stock_logs << stklog
   #                    else 
   #                     amount = amount - outstock.virtual_amount
   #                     outbl = false
   #                     #keyorderdtl=@keyclientorder.keyclientorderdetails.where(business_id: order.business_id,specification_id: orderdtl.specification_id,supplier_id: orderdtl.supplier_id).first
   #                     stklog = StockLog.create(stock: outstock, user: current_user, operation: StockLog::OPERATION[:b2c_stock_out], status: StockLog::STATUS[:waiting], amount: outstock.virtual_amount, operation_type: StockLog::OPERATION_TYPE[:out])
   #                     orderdtl.stock_logs << stklog
   #                     outstock.update_attribute(:virtual_amount , 0)
   #                     outstock.save
   #                    end
   #                  end
   #                 end
   #               end
   #            end

   #        end
   #        sklogs += orderdtl.stock_logs
   #    end
   #      order.update_attribute(:is_shortage,"no")
   #   else
   #     chkout += 1
   #     order.update_attribute(:is_shortage,"yes")
   #   end
   #  end

   # end
   #  #@orders.update_all(status: "unchecked",user_id: nil)
    @stock_logs = StockLog.where(id: sklogs)
    #binding.pry
    @stock_logs_grid = initialize_grid(@stock_logs)
   #  if chkout > 0
   #   flash.now[:notice] = "注意有"+chkout.to_s+"件订单缺货"
    end
   #  #binding.pry
      rescue Exception => e
        Rails.logger.error e.backtrace
        flash[:alert] = e.message
        redirect_to :action => 'findprintindex'
        raise ActiveRecord::Rollback
      end
    end
  end

  def key_check_out_stocks(keyorder)
       orderchk = true
       has_out=0
       keyorder.keyclientorderdetails.each do |kdl|
         outstocks = Stock.find_stocks_in_storage(kdl.specification, kdl.supplier, keyorder.business, current_storage)
         sls=keyorder.stock_logs.where(stock_id: outstocks.to_ary).distinct
         sls.each do |sl|
           has_out += sl.amount
         end

         if kdl.amount*keyorder.orders.count - has_out > 0
           if outstocks.sum(:virtual_amount) - kdl.amount * keyorder.orders.count + has_out >= 0
              chkout = true
           else 
              chkout = false
           end
           orderchk= orderchk && chkout
         end
       end
    return orderchk
  end

  def get_has_cnt(keyorder)
      mi_cnt=keyorder.orders.count
      has_out=0
      keyorder.keyclientorderdetails.each do |kdl|
         outstocks = Stock.find_stocks_in_storage(kdl.specification, kdl.supplier, keyorder.business, current_storage)
         sls=keyorder.stock_logs.where(stock_id: outstocks.to_ary).distinct
         sls.each do |sl|
           has_out += sl.amount
         end
         if outstocks.sum(:virtual_amount)- kdl.amount * keyorder.orders.count + has_out < 0 
            has_cnt = outstocks.sum(:virtual_amount)/kdl.amount
            if has_cnt < mi_cnt
              mi_cnt=has_cnt
            end
         end
       end
      return mi_cnt
  end

  def ordercheck

      @keyclientorder=Keyclientorder.find(params[:format])
      @orders=@keyclientorder.orders
      # b2c
      @orders.each do |order|
        order.stock_logs.each do |stlog|
          stlog.check
        end
        order.stock_out
      end
      #b2b
      if !@keyclientorder.keyclientorderdetails.blank?
        stock_logs = StockLog.where(keyclientorderdetail_id: @keyclientorder.keyclientorderdetails)
        stock_logs.each do |stlog|
          stlog.check
        end
      end

     if @keyclientorder.keyclient_name == "auto"
        redirect_to :action => 'findprintindex'
     else
        redirect_to "/keyclientorders"
     end

  end

  def packout
      @order_details=[]
      @curr_order=""
      @orders = Order.where("storage_id = ?", session[:current_storage].id)
      @orders_grid=initialize_grid(@orders)
  end

  def findorderout
      @_tracking_number = params[:_tracking_number]
      @tracking_number = params[:tracking_number]

      if !@_tracking_number.blank?
        @order_details = []
        @curr_order = 0

        order = Order.find(params[:orderid])
        @curr_order = order.id
      # @order_details=@order.order_details
      # @curr_order=@order.id
        curr_dtls = order.order_details.includes(:specification).where("specifications.sixnine_code = ?",params[:tracking_number]).distinct.first
        if curr_dtls.nil?
           @curr_dtl = -1
        else
           @curr_dtl = curr_dtls.id
        end 
      else
        order = Order.where(tracking_number: @tracking_number, status: "checked").first
        if order.nil?
            @curr_order = 0
            @curr_dtl = 0
        else
          @curr_order = order.id
          @order_details = order.order_details
          @curr_dtl = 0
          @dtl_cnt = order.order_details.count
          @act_cnt = 0
        end
        # binding.pry
      end
      respond_to do |format|
          format.js 
      end
  end

  def setoutstatus
      @order=Order.find(params[:orderid])
      @order.update_attribute(:status, "packed")
  end

  def findprintindex
    status = ["waiting","printed","picking"]
     @orders_grid = initialize_grid(@orders,
                   :include => [:business],
                   :conditions => ['order_type = ? and status in (?)',"b2c",status],
                   :per_page => 15)
     @allcnt = {}
     @allcnt.clear
     @slorders = initialize_grid(@orders, :include => [:business], :conditions => {:order_type => "b2c",:status => "waiting"}).resultset.limit(nil).to_ary
     @selectorders=Order.where(id: @slorders)
     if !params[:grid].nil?
      if !params[:grid][:f].nil?
       if !params[:grid][:f]["businesses.name".to_sym].nil?
        businessid=Business.where("name = ?",params[:grid][:f]["businesses.name".to_sym])
        @selectorders=@selectorders.where(:business_id,businessid)
       end

       if !params[:grid][:f][:created_at].nil?
        @selectorders=@selectorders.where(["created_at >= ? and created_at <= ?",params[:grid][:f][:created_at][:fr],params[:grid][:f][:created_at][:to] ])
       end
      end
     end

     @selectorders=@selectorders.to_ary
     @selectorders.each do |o|
      o.order_details.each do |d|
        product = [o.business_id,d.specification_id,d.supplier_id]
        if @allcnt.has_key?(product)
            @allcnt[product][0]=@allcnt[product][0]+d.amount
        else
            @allcnt[product]=[d.amount]
        end
      end
     end
     #binding.pry

  end

  def standard_orders_import
    unless request.get?
      if file = upload_pingan(params[:file]['file'])
        Keyclientorder.transaction do
          business_id = params[:business_select]
          # supplier_no = params[:supplier_select]
          business = Business.accessible_by(current_ability).find business_id
          # supplier = Supplier.find_by no: supplier_no
          Rails.logger.info "*************business_id:" + business_id + "************"
          # puts "*************" + supplier_no + "************"
          begin
            instance=nil
            if file.include?('.xlsx')
              instance= Roo::Excelx.new(file)
            elsif file.include?('.xls')
              instance= Roo::Excel.new(file)
            elsif file.include?('.csv')
              instance= Roo::CSV.new(file)
            end
            instance.default_sheet = instance.sheets.first

            keyclientorder=Keyclientorder.create! keyclient_name: "标准导入订单 "+DateTime.parse(Time.now.to_s).strftime('%Y-%m-%d %H:%M:%S').to_s, business_id: business.id, unit_id: current_user.unit.id, storage_id: current_storage.id
            2.upto(instance.last_row) do |line|
              sku_ids = instance.cell(line,'A')
              if sku_ids.blank?
                raise "导入文件第" + line.to_s + "行数据, 缺少sku，导入失败"
              end
              sku_ids = sku_ids.split(',')
              Rails.logger.info sku_ids
              amounts = instance.cell(line,'C')
              if amounts.blank?
                raise "导入文件第" + line.to_s + "行数据, 缺少数量，导入失败"
              end
              amounts = amounts.split(',')
              Rails.logger.info amounts
              supplier_names = instance.cell(line,'I')
              if !supplier_names.blank?
                supplier_names = supplier_names.split(',')
              else
                supplier_names = []
              end
              Rails.logger.info supplier_names
              specifications = Specification.accessible_by(current_ability).where sku: sku_ids
              suppliers = Supplier.accessible_by(current_ability).where name: supplier_names

              # relationship = Relationship.find_relationships(instance.cell(2,'C').to_s.split('.0')[0],nil,nil, StorageConfig.config["business"]['pajf_id'], current_user.unit.id)
              
              if specifications.size != sku_ids.size
                # flash[:alert] = "导入文件第" + line.to_s + "行数据, 商品缺失，导入失败"
                raise "导入文件第" + line.to_s + "行数据, 商品缺失，导入失败"
              elsif sku_ids.size != amounts.size
                # flash[:alert] = "导入文件第" + line.to_s + "行数据, sku与数量个数不符，导入失败"
                raise "导入文件第" + line.to_s + "行数据, sku与数量个数不符，导入失败"
              else
                # keyclientorderdetails = Keyclientorderdetail.create! specification: specification, keyclientorder: keyclientorder, amount: instance.cell(2,'B').to_s.split('.0')[0], supplier: supplier, business_id: business.id
                supplier_name_size = 0
                supplier_names.each do |name|
                  if !name.blank?
                    supplier_name_size = +1
                  end
                end
                Rails.logger.info suppliers.size
                Rails.logger.info supplier_name_size
                if suppliers.size != supplier_name_size
                  # flash[:alert] = "导入文件第" + line.to_s + "行数据, 供应商不存在，导入失败"
                  raise "导入文件第" + line.to_s + "行数据, 供应商不存在，导入失败"
                end
                buyer_desc = instance.cell(line,'J')
                order = Order.create! order_type: 'b2c', customer_name: instance.cell(line,'D'), customer_phone: instance.cell(line,'E').to_s.split('.0')[0], city: instance.cell(line,'H'), customer_address: instance.cell(line,'F'), customer_postcode: instance.cell(line,'G').to_s.split('.0')[0], business: business, unit_id: current_user.unit.id, storage_id: current_user.unit.default_storage.id, status: 'waiting', keyclientorder: keyclientorder, buyer_desc: buyer_desc
                # order = Order.create! business_trans_no: instance.cell(line,'A').to_s.split('.0')[0], order_type: 'b2b', customer_name: instance.cell(line,'D'), customer_phone: instance.cell(line,'E').to_s.split('.0')[0], city: instance.cell(line,'H'), customer_address: instance.cell(line,'F'), customer_postcode: instance.cell(line,'G').to_s.split('.0')[0], total_amount: 1, business_id: StorageConfig.config["business"]['pajf_id'], unit_id: current_user.unit.id, storage_id: current_user.unit.default_storage.id, status: 'waiting', customer_idnumber: instance.cell(line,'B').to_s.split('.0')[0], keyclientorder: keyclientorder
                0.upto(sku_ids.size - 1) do |x|
                  specification = specifications.find_by sku: sku_ids[x]
                  name = supplier_names[x].blank?? "":supplier_names[x]
                  supplier = suppliers.find_by name: name
                  OrderDetail.create! name: specification.name,batch_no: nil, specification: specification, amount: amounts[x], supplier: supplier, order: order
                end
              end
            end
            flash[:alert] = "导入成功"
          rescue Exception => e
            Rails.logger.error e.backtrace
            flash[:alert] = e.message
            raise ActiveRecord::Rollback
          end
        end
      end   
    end
  end

  def pingan_b2c_import
    unless request.get?
      if file = upload_pingan(params[:file]['file'])       
        Keyclientorder.transaction do
          begin
            instance=nil
            if file.include?('.xlsx')
              instance= Roo::Excelx.new(file)
            elsif file.include?('.xls')
              instance= Roo::Excel.new(file)
            elsif file.include?('.csv')
              instance= Roo::CSV.new(file)
            end
            instance.default_sheet = instance.sheets.first

          #  keyclientorder=Keyclientorder.create! keyclient_name: "平安线上 "+DateTime.parse(Time.now.to_s).strftime('%Y-%m-%d %H:%M:%S').to_s, business_id: StorageConfig.config["business"]['pajf_id'], unit_id: current_user.unit.id, storage_id: current_storage.id
            # keyclientorder = nil
            2.upto(instance.last_row) do |line|
              city=nil
              if instance.cell(line,'G').include?("市")
                city=instance.cell(line,'G').split("市")[0]+"市"
              else
                city=instance.cell(line,'G').split("县")[0]+"县"
              end
              relationship = Relationship.find_relationships(instance.cell(line,'B').to_s.split('|')[1],nil,nil,nil, current_user.unit.id)
			   #     relationship1 = Relationship.find_relationships(instance.cell(line,'B').to_s.split('|')[1],nil,nil, StorageConfig.config["business"]['pajf_id'], current_user.unit.id)
              transport_type = findTransportType(relationship.specification)
              # if keyclientorder.nil?
              #   keyclientorder=Keyclientorder.create! keyclient_name: "批量导入 "+DateTime.parse(Time.now.to_s).strftime('%Y-%m-%d %H:%M:%S').to_s, business_id: relationship.business_id, unit_id: current_user.unit.id, storage_id: current_storage.id
              # end
              # order = Order.create! business_order_id: instance.cell(line,'J').to_s.split('|')[1],business_trans_no: instance.cell(line,'K').to_s.split('|')[1], order_type: 'b2c', customer_name: instance.cell(line,'F'), customer_phone: instance.cell(line,'H').to_s.split('.0')[0], city: city, customer_address: instance.cell(line,'G'), customer_postcode: instance.cell(line,'P').to_s.split('.0')[0], total_amount: instance.cell(line,'D'), business_id: relationship.business_id, unit_id: current_user.unit.id, storage_id: current_user.unit.default_storage.id, status: 'waiting', pingan_ordertime: instance.cell(line,'A'), pingan_operate: instance.cell(line,'E'), customer_idnumber: instance.cell(line,'I').to_s.split('|')[1], keyclientorder: keyclientorder, transport_type: transport_type
              order = Order.create! business_order_id: instance.cell(line,'J').to_s.split('|')[1],business_trans_no: instance.cell(line,'K').to_s.split('|')[1], order_type: 'b2c', customer_name: instance.cell(line,'F'), customer_phone: instance.cell(line,'H').to_s.split('.0')[0], city: city, customer_address: instance.cell(line,'G'), customer_postcode: instance.cell(line,'P').to_s.split('.0')[0], total_amount: instance.cell(line,'D'), business_id: relationship.business_id, unit_id: current_user.unit.id, storage_id: current_user.unit.default_storage.id, status: 'waiting', pingan_ordertime: instance.cell(line,'A'), pingan_operate: instance.cell(line,'E'), customer_idnumber: instance.cell(line,'I').to_s.split('|')[1], transport_type: transport_type

              OrderDetail.create! name: instance.cell(line,'C'),batch_no: instance.cell(line,'N').to_s.split('|')[1], specification: relationship.specification, amount: instance.cell(line,'D'), supplier: relationship.supplier, order: order
            end
            flash[:alert] = "导入成功"
          rescue Exception => e
            Rails.logger.error e.backtrace
            flash[:alert] = e.message
            raise ActiveRecord::Rollback
          end
        end
      end   
    end
  end

  def pingan_b2b_import
    unless request.get?
      if file = upload_pingan(params[:file]['file'])
        Keyclientorder.transaction do
          begin
            instance=nil
            if file.include?('.xlsx')
              instance= Roo::Excelx.new(file)
            elsif file.include?('.xls')
              instance= Roo::Excel.new(file)
            elsif file.include?('.csv')
              instance= Roo::CSV.new(file)
            end
            instance.default_sheet = instance.sheets.first

            relationship = Relationship.find_relationships(instance.cell(2,'C').to_s.split('.0')[0],nil,nil, StorageConfig.config["business"]['pajf_id'], current_user.unit.id)
            
            if !relationship.nil?
              keyclientorder=Keyclientorder.create! keyclient_name: "平安线下 "+DateTime.parse(Time.now.to_s).strftime('%Y-%m-%d %H:%M:%S').to_s, business_id: StorageConfig.config["business"]['pajf_id'], unit_id: current_user.unit.id, storage_id: current_storage.id
              keyclientorderdetails=Keyclientorderdetail.create! specification: relationship.specification, keyclientorder: keyclientorder, amount: 1, supplier: relationship.supplier, business_id: StorageConfig.config["business"]['pajf_id']
              
              2.upto(instance.last_row) do |line|
                
                order = Order.create! business_trans_no: instance.cell(line,'A').to_s.split('.0')[0], order_type: 'b2b', customer_name: instance.cell(line,'D'), customer_phone: instance.cell(line,'E').to_s.split('.0')[0], city: instance.cell(line,'H'), customer_address: instance.cell(line,'F'), customer_postcode: instance.cell(line,'G').to_s.split('.0')[0], total_amount: 1, business_id: StorageConfig.config["business"]['pajf_id'], unit_id: current_user.unit.id, storage_id: current_user.unit.default_storage.id, status: 'waiting', customer_idnumber: instance.cell(line,'B').to_s.split('.0')[0], keyclientorder: keyclientorder
                
              end
              flash[:alert] = "导入成功"
            else
              flash[:alert] = "商品关联缺失，导入失败"
            end
          rescue Exception => e
            Rails.logger.error e.backtrace
            flash[:alert] = e.message
            raise ActiveRecord::Rollback
          end
        end
      end   
    end
  end

  def orders_b2b_import
    unless request.get?
      if file = upload_pingan(params[:file]['file'])
        Keyclientorder.transaction do
          business_id = params[:business_select]
          supplier_id = params[:supplier_select]
          business = Business.find business_id
          supplier = Supplier.find supplier_id
          Rails.logger.info "*************" + business_id + "************"
          Rails.logger.info "*************" + supplier_id + "************"
          begin
            instance=nil
            if file.include?('.xlsx')
              instance= Roo::Excelx.new(file)
            elsif file.include?('.xls')
              instance= Roo::Excel.new(file)
            elsif file.include?('.csv')
              instance= Roo::CSV.new(file)
            end
            instance.default_sheet = instance.sheets.first

            specification = Specification.find_by sku: instance.cell(2,'A')
            # relationship = Relationship.find_relationships(instance.cell(2,'C').to_s.split('.0')[0],nil,nil, StorageConfig.config["business"]['pajf_id'], current_user.unit.id)
            
            if !specification.nil?
              keyclientorder=Keyclientorder.create! keyclient_name: "标准线下 "+DateTime.parse(Time.now.to_s).strftime('%Y-%m-%d %H:%M:%S').to_s, business_id: business.id, unit_id: current_user.unit.id, storage_id: current_storage.id
              keyclientorderdetails = Keyclientorderdetail.create! specification: specification, keyclientorder: keyclientorder, amount: instance.cell(2,'B').to_s.split('.0')[0], supplier: supplier, business_id: business.id
              
              2.upto(instance.last_row) do |line|
                order = Order.create! order_type: 'b2b', customer_name: instance.cell(line,'C'), customer_phone: instance.cell(line,'D').to_s.split('.0')[0], city: instance.cell(line,'G'), customer_address: instance.cell(line,'E'), customer_postcode: instance.cell(line,'F').to_s.split('.0')[0], total_amount: instance.cell(line,'B').to_s.split('.0')[0], business: business, unit_id: current_user.unit.id, storage_id: current_user.unit.default_storage.id, status: 'waiting', keyclientorder: keyclientorder
                # order = Order.create! business_trans_no: instance.cell(line,'A').to_s.split('.0')[0], order_type: 'b2b', customer_name: instance.cell(line,'D'), customer_phone: instance.cell(line,'E').to_s.split('.0')[0], city: instance.cell(line,'H'), customer_address: instance.cell(line,'F'), customer_postcode: instance.cell(line,'G').to_s.split('.0')[0], total_amount: 1, business_id: StorageConfig.config["business"]['pajf_id'], unit_id: current_user.unit.id, storage_id: current_user.unit.default_storage.id, status: 'waiting', customer_idnumber: instance.cell(line,'B').to_s.split('.0')[0], keyclientorder: keyclientorder
                
              end
              flash[:alert] = "导入成功"
            else
              flash[:alert] = "商品缺失，导入失败"
            end
          rescue Exception => e
            Rails.logger.error e.backtrace
            flash[:alert] = e.message
            raise ActiveRecord::Rollback
          end
        end
      end   
    end
  end

  def upload_pingan(file)
     if !file.original_filename.empty?
       direct = "#{Rails.root}/upload/pingan/"
       filename = "#{Time.now.to_f}_#{file.original_filename}"

       file_path = direct + filename
       File.open(file_path, "wb") do |f|
          f.write(file.read)
       end
       file_path
     end
  end

  def upload_orders_import(file)
     if !file.original_filename.empty?
       direct = "#{Rails.root}/upload/orders_import/"
       filename = "#{Time.now.to_f}_#{file.original_filename}"

       file_path = direct + filename
       File.open(file_path, "wb") do |f|
          f.write(file.read)
       end
       file_path
     end
  end

  def pingan_b2c_outport
  end

  def pingan_b2c_xls_outport
    @keyclientorder=Keyclientorder.where(batch_no: params[:keyclientorder_id]).first
    if @keyclientorder.nil?
       flash[:alert] = "无此批次编号"
       redirect_to :action => 'pingan_b2c_outport'
    else
      @orders=@keyclientorder.orders 
      respond_to do |format|  
        format.xls {   
          send_data(b2c_xls_content_for(@orders),  
                :type => "text/excel;charset=utf-8; header=present",  
                :filename => "Report_Users_#{Time.now.strftime("%Y%m%d")}.xls")  
        }  
      end
    end
  end

  def pingan_b2b_outport
  end

  def pingan_b2b_xls_outport
    @keyclientorder=Keyclientorder.where(batch_no: params[:keyclientorder_id]).first
    if @keyclientorder.nil?
       flash[:alert] = "无此批次编号"
       redirect_to :action => 'pingan_b2b_outport'
    else
      @orders=@keyclientorder.orders 
      respond_to do |format|  
        format.xls {   
          send_data(b2b_xls_content_for(@orders),  
                :type => "text/excel;charset=utf-8; header=present",  
                :filename => "Report_Users_#{Time.now.strftime("%Y%m%d")}.xls")  
        }  
      end
    end
  end

  def importorders()
    unless request.get?
      if file = upload_pingan(params[:file]['file'])       
        Order.transaction do
          begin
            instance=nil
            if file.include?('.xlsx')
              instance= Roo::Excelx.new(file)
            elsif file.include?('.xls')
              instance= Roo::Excel.new(file)
            elsif file.include?('.csv')
              instance= Roo::CSV.new(file)
            end
            instance.default_sheet = instance.sheets.first

            koid = ""
            flash_message = "导入成功!!\<br/\>"
            2.upto(instance.last_row) do |line|
              order = Order.find(instance.cell(line,'A').to_s.split('.0')[0])
              if order.blank?
                raise "导入文件第" + line.to_s + "行数据, 订单不存在，导入失败"
              elsif !order.can_import()
                flash_message << "导入文件第" + line.to_s + "行数据, 订单已处理，无法导入\<br/\>"
                next
              end
              tracking_number = instance.cell(line,'S').to_s.split('|')[1]
              if tracking_number.blank?
                next
              end
              transport_type = instance.cell(line,'R').to_s
              trackingNumber = getTrackingNumber(transport_type, tracking_number, line)
              case trackingNumber[1].size
              when 8
                order.tracking_number=trackingNumber[0] + trackingNumber[1] + checkTrackingNO(trackingNumber[1]).to_s + trackingNumber[2]
              when 11
                order.tracking_number=trackingNumber[0] + trackingNumber[1]
              end
              order.transport_type=transport_type
              # order.status='printed'
              order.set_status('printed')
              order.user_id=current_user.id
              # if order.keyclientorder_id.blank?
                if koid.blank?
                  koid = getKeycOrderID()
                end
                order.keyclientorder_id=koid
              # else
                # koid = order.keyclientorder_id
              # end
              order.save
            end
            flash[:notice] = flash_message
          rescue Exception => e
            Rails.logger.error e.backtrace
            flash[:alert] = e.message
            raise ActiveRecord::Rollback
          end
        end
      end   
    end
  end

  def exportorders()
    x = params[:ids].split(",")
    @orders = Order.where(id: x, status: "waiting")
    # @orders = Order.find(x)

    #@orders = Order.where(" order_type = ? and status = ? ","b2c","waiting").joins("LEFT JOIN order_details ON order_details.order_id = orders.id").order("order_details.specification_id").distinct
    
    if @orders.nil?
       flash[:alert] = "无订单"
       redirect_to :action => 'findprintindex'
    else
      respond_to do |format|
        format.xls {   
          send_data(exportorders_xls_content_for(find_has_stock(@orders,false)),  
                :type => "text/excel;charset=utf-8; header=present",  
                :filename => "Orders_#{Time.now.strftime("%Y%m%d")}.xls")  
        }  
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    #def set_order
    #  @order = Order.find(params[:id])
    #end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:no,:order_type, :need_invoice ,:customer_name,:customer_unit ,:customer_tel,:customer_phone,:province,:city,:county,:customer_address,:customer_postcode,:customer_email,:total_weight,:total_price ,:total_amount,:transport_type,:transport_price,:pay_type,:status,:buyer_desc,:seller_desc,:business_id,:unit_id,:storage_id,:keyclientorder_id)
    end

    def b2c_xls_content_for(objs)  
      xls_report = StringIO.new  
      book = Spreadsheet::Workbook.new  
      sheet1 = book.create_worksheet :name => "Orders"  
    
      blue = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 10  
      sheet1.row(0).default_format = blue  
  
      sheet1.row(0).concat %w{订单生成时间 产品编号 兑换品名称 兑换品数量 操作类型 收件人名称 收件人地址 联系电话 身份证后四位 订单编号 行项目编号 签收时间 配送结果 操作批次号 供应商名称 邮编 承运商 快递单号}  
      count_row = 1
      objs.each do |obj|  
        sheet1[count_row,0]=obj.pingan_ordertime
        sheet1[count_row,1]="|"+Relationship.where("business_id=? and supplier_id=? and specification_id=?",obj.business_id,obj.order_details.first.supplier_id,obj.order_details.first.specification_id).first.external_code.to_s
        sheet1[count_row,2]=obj.order_details.first.name
        sheet1[count_row,3]=obj.order_details.first.amount
        sheet1[count_row,4]=obj.pingan_operate
        sheet1[count_row,5]=obj.customer_name
        sheet1[count_row,6]=obj.customer_address
        sheet1[count_row,7]=obj.customer_phone
        sheet1[count_row,8]="|"+obj.customer_idnumber.to_s
        sheet1[count_row,9]="|"+obj.business_order_id.to_s
        sheet1[count_row,10]="|"+obj.business_trans_no.to_s
        sheet1[count_row,11]=""
        sheet1[count_row,12]=""
        sheet1[count_row,13]="|"+obj.order_details.first.batch_no.to_s
        sheet1[count_row,14]=Supplier.find(obj.order_details.first.supplier_id).name
        sheet1[count_row,15]=obj.customer_postcode
        sheet1[count_row,16]=obj.transport_type
        sheet1[count_row,17]="|"+obj.tracking_number.to_s
       count_row += 1
      end  
  
      book.write xls_report  
      xls_report.string  
    end

    def b2b_xls_content_for(objs)  
      xls_report = StringIO.new  
      book = Spreadsheet::Workbook.new  
      sheet1 = book.create_worksheet :name => "Orders"  
    
      blue = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 10  
      sheet1.row(0).default_format = blue  
  
      sheet1.row(0).concat %w{序号 客户号 礼品 姓名 电话 地址 邮编 城市 投诉时间 客诉原因 运单号}  
      count_row = 1
      objs.each do |obj|  
        sheet1[count_row,0]=obj.business_trans_no
        sheet1[count_row,1]=obj.customer_idnumber
        sheet1[count_row,2]="|"+Relationship.where("business_id=? and supplier_id=? and specification_id=?",obj.business_id,obj.order_details.first.supplier_id,obj.order_details.first.specification_id).first.external_code
        sheet1[count_row,3]=obj.customer_name
        sheet1[count_row,4]=obj.customer_phone
        sheet1[count_row,5]=obj.customer_address
        sheet1[count_row,6]=obj.customer_postcode
        sheet1[count_row,7]=obj.city
        sheet1[count_row,8]=""
        sheet1[count_row,9]=""
        sheet1[count_row,10]="|"+obj.tracking_number.to_s
       count_row += 1
      end  
  
      book.write xls_report  
      xls_report.string  
    end

    def findTransportType(specification)
      #default transport type
      type = "gnxb"
      long = specification.long
      wide = specification.wide
      high = specification.high
      weight = specification.weight
      if !long.nil? && !wide.nil? && !high.nil? && !weight.nil? && (long > 60 || wide > 60 || high > 60 || long + wide + high > 100 || weight > 3000)
        type = "ems"
      end
      return type
    end

    def exportorders_xls_content_for(objs)  
      xls_report = StringIO.new  
      book = Spreadsheet::Workbook.new  
      sheet1 = book.create_worksheet :name => "Orders"  
    
      blue = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 10  
      sheet1.row(0).default_format = blue  
  
      sheet1.row(0).concat %w{订单ID 订单生成时间 产品编号 兑换品名称 兑换品数量 操作类型 收件人名称 收件人地址 联系电话 身份证后四位 订单编号 行项目编号 签收时间 配送结果 操作批次号 供应商名称 邮编 承运商 快递单号}  
      count_row = 1
      objs.each do |obj|
        column2 = "|"  # 产品编号
        column3 = ""  # 兑换品名称
        column4 = ""  # 兑换品数量
        column14 = "|" # 操作批次号
        column15 = "" # 供应商名称
        i = 0
        obj.order_details.each do |detail|
          if detail.supplier.blank?
            column2 += add_text(i,"")
            column15 += add_text(i,"")
          else
            column2 += add_text(i,Relationship.where("business_id=? and supplier_id=? and specification_id=?",obj.business_id,detail.supplier_id,detail.specification_id).first.external_code.to_s)
            column15 += add_text(i,Supplier.find(detail.supplier_id).name)
          end
          column3 += add_text(i,detail.name)
          column4 += add_text(i,detail.amount.to_s)
          column14 += add_text(i,detail.batch_no.to_s)
          i += 1
        end  
        sheet1[count_row,0]=obj.id
        sheet1[count_row,1]=obj.pingan_ordertime

        sheet1[count_row,2]=column2
        sheet1[count_row,3]=column3
        sheet1[count_row,4]=column4
        sheet1[count_row,5]=obj.pingan_operate
        sheet1[count_row,6]=obj.customer_name
        sheet1[count_row,7]=obj.customer_address
        sheet1[count_row,8]=obj.customer_phone
        sheet1[count_row,9]="|"+obj.customer_idnumber.to_s
        sheet1[count_row,10]="|"+obj.business_order_id.to_s
        sheet1[count_row,11]="|"+obj.business_trans_no.to_s
        sheet1[count_row,12]=""
        sheet1[count_row,13]=""
        sheet1[count_row,14]=column14
        sheet1[count_row,15]=column15
        sheet1[count_row,16]=obj.customer_postcode
        sheet1[count_row,17]=obj.transport_type
        sheet1[count_row,18]="|"+obj.tracking_number.to_s
       count_row += 1
      end  
  
      book.write xls_report  
      xls_report.string  
    end

    def getTrackingNumber(transport_type, tracking_number, line=nil)
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
        else
          raise (line.blank?? "":"导入文件第"+line.to_s+"行,") + "同城速递邮件编号格式错误,导入失败"
        end
      when "gnxb"
        case tracking_number.size
        when 13
          return_no << tracking_number[0,2] << tracking_number[2,11] << ""
        else
          raise (line.blank?? "":"导入文件第"+line.to_s+"行,") + "国内小包邮件编号格式错误,导入失败"
        end
      when "ems"
        case tracking_number.size
        when 13
          return_no << tracking_number[0,2] << tracking_number[2,8] << tracking_number[11,2]
        when 10
          return_no << tracking_number[0,2] << tracking_number[2,8] << "06"
        when 8
          return_no << "10" << tracking_number << "06"
        else
          raise (line.blank?? "":"导入文件第"+line.to_s+"行,") + "ems邮件编号格式错误,导入失败"
        end
      else
        raise (line.blank?? "":"导入文件第"+line.to_s+"行,") + "错误的承运商,导入失败"
      end
      return return_no  
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

    def getKeycOrderID()
      time = Time.new
      batch_no = time.year.to_s+time.month.to_s.rjust(2,'0')+time.day.to_s.rjust(2,'0')+Keyclientorder.count.to_s.rjust(5,'0')
      keycorder = Keyclientorder.create(keyclient_name: "auto",unit_id: current_user.unit_id,storage_id: session[:current_storage].id,batch_no: batch_no,user: current_user,status: "printed")
      return keycorder.id
    end

    def add_text(index,content)
      index == 0? content:(","+content)
    end
end
