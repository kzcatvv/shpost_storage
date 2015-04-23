class OrdersController < ApplicationController
  load_and_authorize_resource
  user_logs_filter only: [:orders_import], symbol: "订单导入回馈 #{DateTime.parse(Time.now.to_s).strftime('%Y-%m-%d %H:%M:%S').to_s}", ids: :ids, operation: '订单导入回馈', object: :keyclientorder, parent: :keyclientorder,import_type: "#{import_type}"
  # user_logs_filter only: [:standard_orders_import2], symbol: "订单导入 #{DateTime.parse(Time.now.to_s).strftime('%Y-%m-%d %H:%M:%S').to_s}", ids: :ids, operation: '订单导入'
  # user_logs_filter only: [:exportorders], operation: '订单导出'
  # user_logs_filter only: [:importorders2], symbol: :keyclient_name, operation: '面单信息回馈', object: :keyclientorder, parent: :keyclientorder
  user_logs_filter only: [:ordercheck], symbol: :keyclient_name, operation: '批量确认出库', object: :keyclientorder, parent: :keyclientorder
  user_logs_filter only: [:setoutstatus], symbol: :batch_no, operation: '包装出库', object: :order

  @@orders_export = []
  @@orders_query_export = []
  
  # GET /orderes
  # GET /orderes.json
  def index
    # @userlogs=UserLog.all
    # keyclientorders = []
    # operation=['电商确认出库','批量确认出库']
    # if !params[:order_start_date].blank? and !params[:order_start_date]["order_start_date"].blank?
    #   if params[:order_start_date]["order_start_date"].include?'-'
    #     start_date = Date.civil(params[:order_start_date]["order_start_date"].split(/-|\//)[0].to_i,params[:order_start_date]["order_start_date"].split(/-|\//)[1].to_i,params[:order_start_date]["order_start_date"].split(/-|\//)[2].to_i)
    #   else
    #     flash[:alert] = "日期格式不对，应为'yyyy-mm-dd'"
    #     redirect_to (orders_path) and return
    #   end

    #   @userlogs = @userlogs.where("user_logs.created_at>=? and user_logs.operation in (?)",start_date,operation)
      
    #   if params[:order_end_date].blank? or params[:order_end_date]["order_end_date"].blank?
    #     @userlogs.each do |u|
    #       if !u.parent_id.blank?
    #         keyclientorders << u.parent_id
    #       end
    #     end

    #     @orders = @orders.where keyclientorder_id:keyclientorders
    #   end
    # end

    # if !params[:order_end_date].blank? and !params[:order_end_date]["order_end_date"].blank?
    #   if params[:order_end_date]["order_end_date"].include?'-'
    #     end_date = Date.civil(params[:order_end_date]["order_end_date"].split(/-|\//)[0].to_i,params[:order_end_date]["order_end_date"].split(/-|\//)[1].to_i,params[:order_end_date]["order_end_date"].split(/-|\//)[2].to_i)
    #   else
    #     flash[:alert] = "日期格式不对，应为'yyyy-mm-dd'"
    #     redirect_to (orders_path) and return
    #   end
        
    #   @userlogs = @userlogs.where("user_logs.created_at<=? and user_logs.operation in (?)",(end_date+1),operation)

    #   @userlogs.each do |u|
    #     if !u.parent_id.blank?
    #       keyclientorders << u.parent_id
    #     end
    #   end

    #   @orders = @orders.where keyclientorder_id:keyclientorders

    # end


    @orders_grid = initialize_grid(@orders,
     :conditions => {:order_type => "b2c"}, :include => [:business, :keyclientorder, :user_logs],:order => 'created_at', :order_direction => 'desc')
    @orders_grid.with_resultset do |orders|
      @@orders_query_export = orders.order(created_at: :desc)
    end
  end

  def order_alert
    @orders = Order.where( [ "status = ? and storage_id = ? and orders.created_at < ?", 'waiting',current_storage.id, Time.now-Business.find_by(no: StorageConfig.config["business"]['jh_id']).alertday.day]).joins(:business).where('alertday is not null')
    @orders_grid = initialize_grid(@orders)
  end

  def packaging_index
    @orders = Order.accessible_by(current_ability).where(status: Order::PACKAGING_STATUS)
    @orders_grid=initialize_grid(@orders,
        :conditions => ['order_type = ?',"b2c"])

    render :layout => false
  end

  def packaged_index
    @orders = Order.accessible_by(current_ability).where(status: Order::PACKAGED_STATUS).where('created_at > ?', Date.today.to_time)
    @orders_grid=initialize_grid(@orders,
      :conditions => ['order_type = ?',"b2c"])

    render :layout => false
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
    @order = Order.new(order_params)


    @order.order_type = Order::TYPE[:b2c]
    @order.status = Order::STATUS[:waiting]
    @order.unit = current_user.unit
    @order.storage = current_storage

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

  def cancel
    @order.update(status: 'cancel')
    redirect_to action: 'findprintindex'
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
    oid = []
    arrorders = []
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
        if dtlchk
          shortage = "no"
        else
          shortage = "yes"
        end
        OrderDetail.update(d.id, is_shortage: shortage)
        hasstockchk=hasstockchk && dtlchk
      end
      is_shortage = ''
      if hasstockchk
        findorders += Order.where(id: o)
        ordercnt += 1
        is_shortage = 'no'
        oid << o.id
        # binding.pry
      else
        o.order_details.each do |dtl|
          product = [o.business_id,dtl.specification_id,dtl.supplier_id]
          allcnt[product][1]=allcnt[product][1]-dtl.amount
        end
        is_shortage = 'yes'
      end
      Order.update(o.id,is_shortage: is_shortage)
      Rails.logger.info "all product info: " + allcnt.to_s
       #end
    end

    if createKeyCilentOrderFlg
      if ordercnt > 0
        time = Time.new
        # batch_no = time.year.to_s+time.month.to_s.rjust(2,'0')+time.day.to_s.rjust(2,'0')+Keyclientorder.count.to_s.rjust(5,'0')
        @keycorder = Keyclientorder.create(keyclient_name: "auto",unit_id: current_user.unit_id,storage_id: current_storage.id,user: current_user,status: "waiting")
        until oid.blank? do
          x = Order.where(id: oid.pop(1000))
          x.update_all(keyclientorder_id: @keycorder)
          arrorders += x
        end
        # orders=Order.where(id: findorders)
        # orders.update_all(keyclientorder_id: @keycorder)

        allcnt.each do |k,v|
          if v[1] > 0
            Keyclientorderdetail.create(keyclientorder: @keycorder,business_id: k[0],specification_id: k[1],supplier_id: k[2],amount: v[1])
          end
        end
      end
    end
    # orders=Order.where(id: findorders)
    if arrorders.blank?
      until oid.blank? do
        arrorders += Order.where(id: oid.pop(1000))
      end
    end
    return arrorders
    
  end

  def nextbatch
    @keycorder=params[:format]
    @keyclientorder=Keyclientorder.find(params[:format])
    @keyclientorder.update_attribute(:status,"checked")
    redirect_to :action => 'findprint'
  end

  # def keyclientorder_stock_out
  #   if !params[:keyclientorder_id].nil?
  #     sklogs=[]
  #     # chkout=0
  #     has_out = 0
  #     @keycorder = params[:keyclientorder_id]
  #     keyclientorder = Keyclientorder.find(params[:keyclientorder_id])
  #     @orders = keyclientorder.orders
  #     @stock_logs = keyclientorder.stock_logs
  #     if !@stock_logs.blank?
  #       @stock_logs_grid = initialize_grid(@stock_logs)
  #     return @stock_logs_grid
  #   end

  #   if key_check_out_stocks(keyclientorder)
  #     keyordercnt = keyclientorder.orders.count
  #     keyclientorder.orders.each do |od|
  #       od.update_attribute(:is_shortage,"no")
  #     end

  #   else
  #     keyordercnt = get_has_cnt(keyclientorder)

  #     if keyclientorder.stock_logs.distinct.empty?
  #       keyclientorder.orders.limit(keyordercnt).each do |order|
  #         order.update_attribute(:is_shortage,"no")
  #       end

  #       keyclientorder.orders.offset(keyordercnt).each do |o|
  #         o.update_attribute(:is_shortage,"yes")
  #       end
  #     else
  #       keyclientorder.orders.where(is_shortage: "yes").limit(keyordercnt).each do |order|
  #         order.update_attribute(:is_shortage,"no")
  #       end

  #       keyclientorder.orders.where(is_shortage: "yes").offset(keyordercnt).each do |o|
  #         o.update_attribute(:is_shortage,"yes")
  #       end
  #     end
  #   end
  #   chkout=keyclientorder.orders.where(is_shortage: "yes").count

  #   if keyordercnt > 0
  #     keyclientorder.keyclientorderdetails.each do |keydtl|
  #     if keydtl.amount > 0
  #       outstocks = Stock.find_stocks_in_storage(keydtl.specification, keydtl.supplier, keyclientorder.business, current_storage).to_ary
  #       outbl = false
  #       amount = keydtl.amount * keyordercnt
  #       sls=keyclientorder.stock_logs.where(stock_id: outstocks.to_ary).distinct
  #       sls.each do |sl|
  #         has_out += sl.amount
  #       end
  #       koallcnt=keydtl.amount*keyclientorder.orders.count
  #       offsetcnt=has_out
  #       lastamount=0

  #       if koallcnt - has_out > 0
  #         outstocks.each do |outstock|
  #           if outstock.virtual_amount > 0
  #             if !outbl
  #               if outstock.virtual_amount - amount >= 0
  #                 setamount = outstock.virtual_amount - amount
  #                 outbl = true
  #                 outstock.update_attribute(:virtual_amount , setamount)
  #                 outstock.save
  #                 stklog = StockLog.create(stock: outstock, user: current_user, operation: StockLog::OPERATION[:b2b_stock_out], status: StockLog::STATUS[:waiting], amount: amount, operation_type: StockLog::OPERATION_TYPE[:out], keyclientorderdetail_id: keydtl.id)
  #                  #sklogs += StockLog.where(id: stklog)
  #                 ods=keyclientorder.order_details.where(specification_id: keydtl.specification_id,supplier_id: keydtl.supplier_id).offset(offsetcnt/keydtl.amount).limit((lastamount+amount)/keydtl.amount)
  #                  stklog.order_details << ods
  #               else 
  #                 amount = amount - outstock.virtual_amount
  #                 getamount = outstock.virtual_amount
  #                 outbl = false
  #                 stklog = StockLog.create(stock: outstock, user: current_user, operation: StockLog::OPERATION[:b2b_stock_out], status: StockLog::STATUS[:waiting], amount: outstock.virtual_amount, operation_type: StockLog::OPERATION_TYPE[:out], keyclientorderdetail_id: keydtl.id)
  #                  #sklogs += StockLog.where(id: stklog)
  #                 if amount + outstock.virtual_amount == keydtl.amount * keyordercnt
  #                   if getamount/keydtl.amount == 0
  #                     ods = keyclientorder.order_details.where(specification_id: keydtl.specification_id,supplier_id: keydtl.supplier_id).offset(has_out/keydtl.amount).limit(1)
  #                     lastamount=getamount
  #                   else
  #                     lastamount=getamount%keydtl.amount
  #                     if lastamount == 0 
  #                       ods = keyclientorder.order_details.where(specification_id: keydtl.specification_id,supplier_id: keydtl.supplier_id).offset(has_out/keydtl.amount).limit(getamount/keydtl.amount)
  #                     else
  #                       ods = keyclientorder.order_details.where(specification_id: keydtl.specification_id,supplier_id: keydtl.supplier_id).offset(has_out/keydtl.amount).limit(getamount/keydtl.amount+1)
  #                     end
  #                   end
  #                   offsetcnt += getamount
  #                 else
  #                   if (lastamount+getamount)/keydtl.amount == 0
  #                     ods = keyclientorder.order_details.where(specification_id: keydtl.specification_id,supplier_id: keydtl.supplier_id).offset(offsetcnt/keydtl.amount).limit(1)
  #                     lastamount=lastamount+getamount
  #                   else
  #                     lastamount = (lastamount + getamount)%keydtl.amount
  #                     if lastamount == 0
  #                       ods = keyclientorder.order_details.where(specification_id: keydtl.specification_id,supplier_id: keydtl.supplier_id).offset(offsetcnt/keydtl.amount).limit((lastamount+getamount)/keydtl.amount)
  #                     elsstandard_orders_importe
  #                       ods = keyclientorder.order_details.where(specification_id: keydtl.specification_id,supplier_id: keydtl.supplier_id).offset(offsetcnt/keydtl.amount).limit((lastamount+getamount)/keydtl.amount + 1)
  #                     end
  #                   end
  #                   offsetcnt += getamount
  #                     end
  #                     stklog.order_details << ods
  #                     outstock.update_attribute(:virtual_amount , 0)
  #                     outstock.save
  #                   end
  #                 end
  #               end
  #             end
  #           end
  #         end
  #       end
  #     end
  #    # sklogs=StockLog.where(id: keyclientorder.stock_logs)
  #    # details = keyclientorder.keyclientorderdetails
  #    # ids = []
  #    # details.each do |detail|
  #    #   ids << detail.id
  #    # end
  #     @stock_logs = StockLog.where(keyclientorderdetail_id: keyclientorder.keyclientorderdetails)
  #    # puts @stock_logs.size
  #   #binding.pry
  #     @stock_logs_grid = initialize_grid(@stock_logs)

  # end

  # def stockout
  #   begin
  #   Order.transaction do
  #     @keyclientorder = Keyclientorder.find(params[:format])

      # needpick = current_storage.need_pick

      # if needpick
      #   Stock.pick_stock_out(@keyclientorder, current_user)

  #       @stock_logs = @keyclientorder.stock_logs.where(" operation_type = 'out' ")
  #     else

  #       Stock.order_stock_out(@keyclientorder, current_user)

  #       @keyclientorder.orders.each do |order|
  #         order.set_picking
  #       end
      
  #       @stock_logs = @keyclientorder.stock_logs
  #     end
  #       @stock_logs_grid = initialize_grid(@stock_logs)
  #   end
  #   rescue Exception => e
  #     Rails.logger.error e.backtrace
  #     flash[:alert] = e.message
  #     redirect_to :action => 'findprintindex'
  #     # raise ActiveRecord::Rollback
  #   end
  # end

  # def key_check_out_stocks(keyclientorder)
  #   orderchk = true
  #   has_out = 0
  #   keyclientorder.keyclientorderdetails.each do |kdl|
  #     outstocks = Stock.find_stocks_in_storage(kdl.specification, kdl.supplier, keyclientorder.business, current_storage)
  #     sls = keyclientorder.stock_logs.where(stock_id: outstocks.to_ary).distinct

  #     has_out = sls.sum :amount

  #     if kdl.amount * keyclientorder.orders.count - has_out > 0
  #       if outstocks.sum(:virtual_amount) - kdl.amount * keyclientorder.orders.count + has_out >= 0
  #         chkout = true
  #       else 
  #         chkout = false
  #       end
  #       orderchk= orderchk && chkout
  #     end
  #   end
  #   return orderchk
  # end

  # def get_has_cnt(keyorder)
  #   mi_cnt=keyorder.orders.count
  #   has_out=0
  #   keyorder.keyclientorderdetails.each do |kdl|
  #     outstocks = Stock.find_stocks_in_storage(kdl.specification, kdl.supplier, keyorder.business, current_storage)
  #     sls=keyorder.stock_logs.where(stock_id: outstocks.to_ary).distinct
  #     sls.each do |sl|
  #       has_out += sl.amount
  #     end
  #     if outstocks.sum(:virtual_amount)- kdl.amount * keyorder.orders.count + has_out < 0 
  #       has_cnt = outstocks.sum(:virtual_amount)/kdl.amount
  #       if has_cnt < mi_cnt
  #         mi_cnt=has_cnt
  #       end
  #     end
  #   end
  #   return mi_cnt
  # end

#   def ordercheck

#     @keyclientorder=Keyclientorder.find(params[:format])
#     @orders=@keyclientorder.orders
# # b2c
#     @orders.each do |order|
#       order.stock_logs.each do |stlog|
#         stlog.check!
#       end
#       order.stock_out
#     end
#     #b2b
#     if !@keyclientorder.keyclientorderdetails.blank?
#       stock_logs = StockLog.where(keyclientorderdetail_id: @keyclientorder.keyclientorderdetails)
#       stock_logs.each do |stlog|
#         stlog.check!
#       end
#     end

#     if @keyclientorder.keyclient_name == "auto"
#       redirect_to :action => 'findprintindex'
#     else
#       redirect_to "/keyclientorders"
#     end
#   end

  def packout
    @order_details=[]
    @curr_order=""
    @orders = Order.where("storage_id = ?", current_storage.id)
    @orders_grid=initialize_grid(@orders,
      :conditions => ['order_type = ? ',"b2c"])
  end

  def findorderout
    @_tracking_number = params[:_tracking_number]
    @tracking_number = params[:tracking_number]

    if !@_tracking_number.blank?
      @order_details = []
      @curr_order = 0

      order = Order.find(params[:orderid])
      @curr_order = order.id
      curr_dtls_a = order.order_details.includes(:specification).where("specifications.sixnine_code = ? ",params[:tracking_number]).where(desc:nil)
      curr_dtls_b = order.order_details.includes(:specification).where("specifications.sixnine_code = ? ",params[:tracking_number]).where.not(desc: "haspacked")
      curr_dtls_c = curr_dtls_a + curr_dtls_b
      curr_dtls = curr_dtls_c.first
      
      if curr_dtls.nil?
        @curr_dtl = -1
      else
        @curr_dtl = curr_dtls.id
        if curr_dtls.amount == 1
          @curod = OrderDetail.find(curr_dtls.id).update(desc: "haspacked")
        end
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
        if order.order_details.where(desc: 'haspacked').count <= 0
          @act_cnt = 0
        else
          @act_cnt = order.order_details.where(desc: 'haspacked').count
        end
      end
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
    status = ["waiting","spliting","printed","picking"]
    
    @orders_grid = initialize_grid(@orders, :include => [:business, :keyclientorder], :conditions => ['orders.order_type = ? and orders.status in (?) ',"b2c",status],:order => 'orders.keyclientorder_id',
     :order_direction => 'desc', :per_page => 15)

    @orders_grid.with_resultset do |orders|
      @@orders_export = orders
    end

    @allcnt = {}
    @allcnt.clear
    @slorders = initialize_grid(@orders, :include => [:business, :keyclientorder], :conditions => ['orders.order_type = ? and orders.status in (?) ',"b2c",status])

    #some wice_grad lazy do the resultset is [] without once call
    begin
      @slorders.resultset
    rescue

    end
    
    @selectorders=Order.where('order_type = ? and status in (?) and storage_id = ?',"b2c",status, current_storage.id)
    # @selectorders=Order.where(id: @slorders.resultset.limit(nil).to_ary)

    if !params[:grid].nil?
      if !params[:grid][:f].nil?
        if !params[:grid][:f]["businesses.name".to_sym].nil?
          businessid=Business.where("name = ?",params[:grid][:f]["businesses.name".to_sym])
          @selectorders=@selectorders.where(:business_id,businessid)
        end

        if !params[:grid][:f][:created_at].nil?
          @selectorders=@selectorders.where(["orders.created_at >= ? and orders.created_at <= ?",params[:grid][:f][:created_at][:fr],params[:grid][:f][:created_at][:to] ])
        end
      end
    end
    
    selorders = @selectorders
    @selectorders=@selectorders.to_ary
    @selectorders.each do |o|
      o.order_details.each do |d|
        product = [o.business_id,d.specification_id,d.supplier_id]
        order_count = selorders.includes(:order_details).where("orders.business_id=? and order_details.specification_id=? and order_details.supplier_id=?",o.business_id,d.specification_id,d.supplier_id).count

        if @allcnt.has_key?(product)
          @allcnt[product][0]=@allcnt[product][0]+d.amount

        else
          @allcnt[product]=[d.amount,order_count]
        end
      end
    end

  end

=begin
  def standard_orders_import
    unless request.get?
      if file = upload_pingan(params[:file]['file'])
        Keyclientorder.transaction do
          business_id = params[:business_select]
          business = Business.accessible_by(current_ability).find business_id
          Rails.logger.info "*************business_id:" + business_id + "************"
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


              if specifications.size != sku_ids.size
                raise "导入文件第" + line.to_s + "行数据, 商品缺失，导入失败"
              elsif sku_ids.size != amounts.size
                raise "导入文件第" + line.to_s + "行数据, sku与数量个数不符，导入失败"
              else
                supplier_name_size = 0
                supplier_names.each do |name|
                  if !name.blank?
                    supplier_name_size = +1
                  end
                end
                Rails.logger.info suppliers.size
                Rails.logger.info supplier_name_size
                if suppliers.size != supplier_name_size
                  raise "导入文件第" + line.to_s + "行数据, 供应商不存在，导入失败"
                end
                buyer_desc = instance.cell(line,'J')
                order = Order.create! order_type: 'b2c', customer_name: instance.cell(line,'D'), customer_phone: instance.cell(line,'E').to_s.split('.0')[0], city: instance.cell(line,'H'), customer_address: instance.cell(line,'F'), customer_postcode: instance.cell(line,'G').to_s.split('.0')[0], business: business, unit_id: current_user.unit.id, storage_id: current_user.unit.default_storage.id, status: 'waiting', keyclientorder: keyclientorder, buyer_desc: buyer_desc
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
=end

  def standard_orders_import2
    @ids = []
    unless request.get?
      if file = upload_pingan(params[:file]['file'])
        # Order.transaction do
      #商户
          business_id = params[:business_select]
          business = Business.accessible_by(current_ability).find business_id
          Rails.logger.info "*************business_id:" + business_id + "************"
          # begin
            instance=nil
            if file.include?('.xlsx')
              instance= Roo::Excelx.new(file)
            elsif file.include?('.xls')
              instance= Roo::Excel.new(file)
            elsif file.include?('.csv')
              instance= Roo::CSV.new(file)
            end
            sheet1_error = []
            sheet2_error = []
            instance.default_sheet = instance.sheets.first
            
            # @keyclientorder=Keyclientorder.create! keyclient_name: "标准导入订单 "+DateTime.parse(Time.now.to_s).strftime('%Y-%m-%d %H:%M:%S').to_s, business_id: business.id, unit_id: current_user.unit.id, storage_id: current_storage.id
            flash_message = "导入成功!"
            is_shortage = ""
            ords = []
            #从第二行开始一直读取，直到空行 
            line = 2
            # until instance.cell(line,'A').blank? do 
            line.upto(instance.last_row) do |line|
                #物流供应商
                transport_type = instance.cell(line,'C')
                case transport_type
                  when "同城速递","tcsd","TCSD"
                    tran_type = 'tcsd'
                  when "国内小包","gnxb","GNXB"
                    tran_type = 'gnxb'  
                  when "EMS","ems"
                    tran_type = 'ems'
                  when "ttkd","天天快递","TTKD"
                    tran_type = 'ttkd'
                  when "bsht","百世汇通","BSHT"
                    tran_type = 'bsht'
                  when "qt","其他","QT"
                    tran_type = 'qt'
                  else
                    tran_type = nil
                end 
                
                #物流单号
                tracking_number = to_string(instance.cell(line,'B'))
                if tracking_number.blank?
                  tracking_number = nil
                # else
                #   trackingNumber = getTrackingNumber(tran_type, tracking_number, line)
                #   case trackingNumber[1].size
                #   when 8
                #     tracking_number=trackingNumber[0] + trackingNumber[1] + checkTrackingNO(trackingNumber[1]).to_s + trackingNumber[2]
                #   when 11
                #     tracking_number=trackingNumber[0] + trackingNumber[1]
                #   end
                end
                #外部订单号
                business_order_id = to_string(instance.cell(line,'A'))
                if !business_order_id.blank?
                  ori_order = Order.accessible_by(current_ability).find_by  business_order_id: business_order_id, business_id:business_id
                else
                  txt = "缺少外部订单号"
                  sheet1_error << (instance.row(line) << txt)
                  next
                  # raise "导入文件第一页第" + line.to_s + "行数据,缺少外部订单号，导入失败"
                end

                #判断是否已存在该订单
                if ori_order.blank?
                  #不存在创建
                  order = Order.create! order_type: 'b2c',business_order_id: business_order_id, tracking_number: tracking_number, transport_type: tran_type,  total_weight: instance.cell(line,'D').to_f, pingan_ordertime: instance.cell(line,'E'), customer_unit: instance.cell(line,'F'), customer_name: instance.cell(line,'G'), customer_address: instance.cell(line,'H'), customer_postcode: instance.cell(line,'I').to_s.split('.0')[0], province: instance.cell(line,'J'), city: instance.cell(line,'K'), county: instance.cell(line,'L'), customer_tel: instance.cell(line,'M').to_s.split('.0')[0],customer_phone: instance.cell(line,'N').to_s.split('.0')[0], business: business, unit_id: current_user.unit.id, storage_id: current_storage.id, status: 'waiting'

                  ords[0] = order
                  if find_has_stock(ords,false).blank?
                    is_shortage = "yes"
                  else
                    is_shortage = "no"
                  end
                  Order.update(order.id,is_shortage: is_shortage)
                    
                  @ids << order.id
                    
                else
                  #待处理状态才能更新
                  order_status = ori_order.status
                  if (order_status <=> "waiting")==0
                    order_id = ori_order.id.to_s

                    order = Order.update(order_id,tracking_number:tracking_number,transport_type:tran_type,total_weight:instance.cell(line,'D').to_f,pingan_ordertime:instance.cell(line,'E'),customer_unit:instance.cell(line,'F'),customer_name:instance.cell(line,'G'),customer_address:instance.cell(line,'H'),customer_postcode:instance.cell(line,'I').to_s.split('.0')[0],province:instance.cell(line,'J'),city:instance.cell(line,'K'),county:instance.cell(line,'L'),customer_tel:instance.cell(line,'M').to_s.split('.0')[0],customer_phone:instance.cell(line,'N').to_s.split('.0')[0])

                    ords[0] = order
                    if find_has_stock(ords,false).blank?
                      is_shortage = "yes"
                    else
                      is_shortage = "no"
                    end
                    Order.update(order.id,is_shortage: is_shortage)
                    
                    @ids << order_id
                  else
                    txt = "只有待处理状态的订单才能重复导入"
                    sheet1_error << (instance.row(line) << txt)
                    next
                    # raise "导入文件第一页第" + line.to_s + "行数据, 只有待处理状态的订单才能重复导入，导入失败"
                  end
                  
                  line = line+1
                end
            end
            
            #读取订单明细
            #dline = line+2
            instance.default_sheet = instance.sheets.second
            dline = 2
            dline.upto(instance.last_row) do |dline|
              #外部订单号
              business_order_id = to_string(instance.cell(dline,'A'))
              if business_order_id.blank?
                txt = "缺少外部订单号"
                sheet2_error << (instance.row(dline) << txt)
                next
                # raise "导入文件第二页第" + dline.to_s + "行数据, 缺少外部订单号，导入失败"
              end

              #子订单号
              sub_order_id = to_string(instance.cell(dline,'B'))

              #供应商编号
              if !instance.cell(dline,'D').blank?
                supplier_no = instance.cell(dline,'D').to_s.split('.0')[0]
                supplier = Supplier.accessible_by(current_ability).find_by(no: supplier_no)
              end
        
              #SKU/第三方编码/69码
              sku_extcode_69code = to_string(instance.cell(dline,'C'))

              if !sku_extcode_69code.blank?
                #先考虑为sku
                specification = Specification.accessible_by(current_ability).find_by sku: sku_extcode_69code
                #不是sku，考虑为第三方编码
                if specification.blank?
                  relationship = Relationship.accessible_by(current_ability).find_by("business_id = ? and external_code = ?", "#{business_id}","#{sku_extcode_69code}")

                  #不是第三方编码，考虑为69码
                  if relationship.blank?
                    if !supplier.blank?
                      relationship = Relationship.includes(:specification).accessible_by(current_ability).find_by("specifications.sixnine_code=? and relationships.business_id = ? and relationships.supplier_id=?","#{sku_extcode_69code}","#{business_id}","#{supplier.id}")
                      
                    else
                      txt = "69码找不到供应商"
                      sheet1_error = order_add(sheet1_error,0,business_order_id,instance,txt)
                      sheet2_error = detail_add(sheet2_error,0,dline,instance,txt)
                      next
                      # raise "导入文件第二页第" + dline.to_s + "行数据, 69码找不到供应商，导入失败"
                    end
                  end
                  
                  if !relationship.blank?
                    specification = relationship.specification
                    supplier = relationship.supplier
                  else
                    txt = "找不到对应关系"
                    sheet1_error = order_add(sheet1_error,0,business_order_id,instance,txt)
                    sheet2_error = detail_add(sheet2_error,0,dline,instance,txt)
                    next
                    # raise "导入文件第二页第" + dline.to_s + "行数据, 找不到对应关系，导入失败"
                  end
                else
                  if supplier.blank?
                    txt = "sku找不到供应商"
                    sheet1_error = order_add(sheet1_error,0,business_order_id,instance,txt)
                    sheet2_error = detail_add(sheet2_error,0,dline,instance,txt)
                    next
                    # raise "导入文件第二页第" + dline.to_s + "行数据, sku找不到供应商，导入失败"
                  else
                    relationship = Relationship.accessible_by(current_ability).find_by("specification_id = ? and supplier_id = ?", "#{specification.id}","#{supplier.id}")
                    if relationship.blank?
                      txt = "sku找不到对应关系"
                      sheet1_error = order_add(sheet1_error,0,business_order_id,instance,txt)
                      sheet2_error = detail_add(sheet2_error,0,dline,instance,txt)
                      next
                      # raise "导入文件第二页第" + dline.to_s + "行数据, sku找不到对应关系，导入失败"
                    end
                  end
                end
              else
                txt = "缺少sku/第三方编码/69码"
                sheet1_error = order_add(sheet1_error,0,business_order_id,instance,txt)
                sheet2_error = detail_add(sheet2_error,0,dline,instance,txt)
                next
                # raise "导入文件第二页第" + dline.to_s + "行数据, 缺少sku/第三方编码/69码，导入失败"
              end
              
              #数量
              temp_amount = instance.cell(dline,'E').to_s.split('.0')[0]
              if temp_amount.blank?
                txt = "缺少数量"
                sheet1_error = order_add(sheet1_error,0,business_order_id,instance,txt)
                sheet2_error = detail_add(sheet2_error,0,dline,instance,txt)
                next
                # raise "导入文件第二页第" + dline.to_s + "行数据, 缺少数量，导入失败"
              end

              amount = find_in_instance(instance,dline,business_order_id,sku_extcode_69code,supplier_no,sub_order_id,temp_amount)

              #根据外部订单号找到对应订单
               dorder = Order.accessible_by(current_ability).find_by business_order_id: business_order_id, business_id: business_id

              if dorder.blank?
                txt = "详单对应订单不存在"
                sheet1_error = order_add(sheet1_error,0,business_order_id,instance,txt)
                sheet2_error = detail_add(sheet2_error,0,dline,instance,txt)
                next
                # raise "导入文件第二页第" + dline.to_s + "行数据, 详单对应订单不存在，导入失败"
              end

              dorder_id = dorder.id.to_s
              # dorder_total_amount = dorder.order_details.sum(:amount)
              # if dorder_total_amount.blank?
              #   dorder_total_amount = 0
              # end
              
              #只有对应订单状态为待处理，才能更新订单明细
              dorder_status = dorder.status
              if (dorder_status <=> "waiting")==0
                #取得原有订单明细记录
                ori_order_detail = OrderDetail.accessible_by(current_ability).where('supplier_id = ? and specification_id = ? and order_id = ?',"#{supplier.id}","#{specification.id}","#{dorder_id}")
                
                business_deliver_no = ""
                business_trans_no = ""
                if !sub_order_id.blank?
                    business_deliver_no = sub_order_id
                    business_trans_no = dorder.business_order_id
                    if !ori_order_detail.blank?
                      ori_order_detail = ori_order_detail.where(business_deliver_no:sub_order_id)
                    end
                end
                binding.pry
                #原来没有，创建
                if ori_order_detail.blank? 
                  #数量小等于0，跳过
                  if amount.to_i <=0
                    next
                  #数量大于0，创建，同时对应订单数量增加
                  else 
                    OrderDetail.create! name: specification.name,batch_no: nil, specification: specification, amount: amount.to_i, supplier: supplier,business_deliver_no: business_deliver_no, order: dorder
                    Order.update(dorder_id,business_trans_no: business_trans_no)
                    # dorder_total_amount = dorder_total_amount + amount.to_i
                    # Order.update(dorder_id,total_amount: dorder_total_amount,business_trans_no: business_trans_no)
                  end
                #原来有，更新原记录
                else
                  order_detail_id = ori_order_detail.first.id

                  ori_detail_amount = ori_order_detail.first.amount
                  #数量为0，删除该订单明细，同时对应订单数量减少
                  if amount.to_i == 0
                    OrderDetail.destroy(order_detail_id)

                    # dorder_total_amount = dorder_total_amount - ori_detail_amount
                    # Order.update(dorder_id,total_amount: dorder_total_amount)

                  #数量大于0，更新该订单明细，同时对应订单数量改变
                  elsif amount.to_i > 0
                    OrderDetail.update(order_detail_id,amount: amount.to_i,business_deliver_no: business_deliver_no)
                    Order.update(dorder_id,business_trans_no: business_trans_no)
                    # dorder_total_amount = dorder_total_amount - ori_detail_amount + amount.to_i
                    # Order.update(dorder_id,total_amount: dorder_total_amount,business_trans_no: business_trans_no)
                  #数量小于0，报错
                  else
                    txt = "订单明细数量不能负数"
                    sheet1_error = order_add(sheet1_error,0,business_order_id,instance,txt)
                    sheet2_error = detail_add(sheet2_error,0,dline,instance,txt)
                    next
                    # raise "导入文件第二页第" + dline.to_s + "行数据, 订单明细数量不能负数，导入失败"
                  end
                end 
              else
                txt = "只有待处理状态的订单才能重复导入"
                sheet1_error = order_add(sheet1_error,0,business_order_id,instance,txt)
                sheet2_error = detail_add(sheet2_error,0,dline,instance,txt)
                next
                # raise "导入文件第二页第" + dline.to_s + "行数据, 只有待处理状态的订单才能重复导入，导入失败"
              end
            end
            redeal_with_errororder(sheet1_error,1)
            if !sheet1_error.blank? || !sheet2_error.blank?
              flash_message << "有部分订单导入失败！"
            end
            flash[:notice] = flash_message

            respond_to do |format|
              format.xls {   
                if !sheet1_error.blank? && !sheet2_error.blank?
                  send_data(exporterrororders_xls_content_for(sheet1_error,sheet2_error),  
                    :type => "text/excel;charset=utf-8; header=present",  
                    :filename => "Error_Orders_#{Time.now.strftime("%Y%m%d")}.xls")  
                else
                  redirect_to :action => 'findprintindex'
                end
              }
            end

          # rescue Exception => e
          #   Rails.logger.error e.backtrace
          #   flash[:alert] = e.message
          #   raise ActiveRecord::Rollback
          # end
        # end
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

            2.upto(instance.last_row) do |line|
              city=nil
              if instance.cell(line,'G').include?("市")
                city=instance.cell(line,'G').split("市")[0]+"市"
              else
                city=instance.cell(line,'G').split("县")[0]+"县"
              end
              relationship = Relationship.find_relationships(instance.cell(line,'B').to_s.split('|')[1],nil,nil,nil, current_user.unit.id)
              transport_type = findTransportType(relationship.specification)
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

            specification = Specification.accessible_by(current_ability).find_by sku: instance.cell(2,'A')

            if !specification.nil?
              keyclientorder=Keyclientorder.create! keyclient_name: "标准线下 "+DateTime.parse(Time.now.to_s).strftime('%Y-%m-%d %H:%M:%S').to_s, business_id: business.id, unit_id: current_user.unit.id, storage_id: current_storage.id
              keyclientorderdetails = Keyclientorderdetail.create! specification: specification, keyclientorder: keyclientorder, amount: instance.cell(2,'B').to_s.split('.0')[0], supplier: supplier, business_id: business.id

              2.upto(instance.last_row) do |line|
                order = Order.create! order_type: 'b2b', customer_name: instance.cell(line,'C'), customer_phone: instance.cell(line,'D').to_s.split('.0')[0], city: instance.cell(line,'G'), customer_address: instance.cell(line,'E'), customer_postcode: instance.cell(line,'F').to_s.split('.0')[0], total_amount: instance.cell(line,'B').to_s.split('.0')[0], business: business, unit_id: current_user.unit.id, storage_id: current_user.unit.default_storage.id, status: 'waiting', keyclientorder: keyclientorder

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

=begin
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
=end

    def importorders2()
    unless request.get?
      if file = upload_pingan(params[:file]['file'])    
        # Order.transaction do
        #   begin
            instance=nil
            if file.include?('.xlsx')
              instance= Roo::Excelx.new(file)
            elsif file.include?('.xls')
              instance= Roo::Excel.new(file)
            elsif file.include?('.csv')
              instance= Roo::CSV.new(file)
            end
            sheet1_error = []
            sheet2_error = []
            instance.default_sheet = instance.sheets.first
            # binding.pry
            flash_message = "导入成功!"
            koid = getKeycOrderID()
            @keyclientorder = Keyclientorder.find koid

            line = 2
            # until instance.cell(line,'A').blank? do
            line.upto(instance.last_row) do |line|
              batch_no = to_string(instance.cell(line,'P'))

              if batch_no.blank?
                business_order_id = to_string(instance.cell(line,'A'))
                if business_order_id.blank?
                  txt = "缺少外部订单号"
                  sheet1_error << (instance.row(line) << txt)
                  next
                  # raise "导入文件第一页第" + line.to_s + "行数据, 缺少外部订单号，导入失败"
                end

                business_trans_no = to_string(instance.cell(line,'Q'))
                if !business_trans_no.blank?
                  if !business_trans_no.eql?business_order_id
                    business_order_id = business_trans_no
                  end 
                end

                business_name = instance.cell(line,'O')
                if business_name.blank?
                  txt = "缺少商户名称"
                  sheet1_error << (instance.row(line) << txt)
                  next
                  # raise "导入文件第一页第" + line.to_s + "行数据, 缺少商户名称，导入失败"
                end
                business_id = Business.accessible_by(current_ability).find_by(name: business_name).id

                order = Order.accessible_by(current_ability).find_by  business_order_id: business_order_id, business_id: business_id
              else
                order = Order.accessible_by(current_ability).find_by  batch_no: batch_no
              end
              if order.blank?
                txt = "订单不存在"
                sheet1_error << (instance.row(line) << txt)
                next
                # raise "导入文件第一页第" + line.to_s + "行数据, 订单不存在，导入失败"
              elsif !order.can_import()
                flash_message << "导入文件第一页第" + line.to_s + "行数据, 订单已处理，无法导入!"
                next
              end

              if order.status.eql? "waiting" or order.status.eql? "printed"
                tracking_number = to_string(instance.cell(line,'B'))
                if tracking_number.blank?
                  txt = "缺少物流单号"
                  sheet1_error << (instance.row(line) << txt)
                  next
                end
                transport_type = instance.cell(line,'C')
                if transport_type.blank?
                  txt = "缺少物流供应商"
                  sheet1_error << (instance.row(line) << txt)
                  next
                end
                case transport_type
                  when "同城速递","tcsd","TCSD"
                    tran_type = 'tcsd'
                  when "国内小包","gnxb","GNXB"
                    tran_type = 'gnxb'  
                  when "EMS","ems"
                    tran_type = 'ems'
                  when "天天快递","ttkd","TTKD"
                    tran_type = 'ttkd'
                  when "百世汇通","bsht","BSHT"
                    tran_type = 'bsht'
                  when "其他","qt","QT"
                    tran_type = 'qt'
                  else
                    tran_type = nil
                end
                # trackingNumber = getTrackingNumber(tran_type, tracking_number, line)
                # case trackingNumber[1].size
                # when 8
                #   order.tracking_number=trackingNumber[0] + trackingNumber[1] + checkTrackingNO(trackingNumber[1]).to_s + trackingNumber[2]
                # when 11
                #   order.tracking_number=trackingNumber[0] + trackingNumber[1]
                # end
                order.tracking_number = tracking_number
                order.transport_type=tran_type
                order.set_status('printed')
                order.user_id=current_user.id
                order.keyclientorder_id=koid
                # koid = order.keyclientorder_id
                # if koid.blank?
                #   if line ==2
                #     nkoid = getKeycOrderID()
                #   end
                #   order.keyclientorder_id=nkoid
                #   @keyclientorder = Keyclientorder.find nkoid
                # else
                #   @keyclientorder = Keyclientorder.find koid
                # end
                                              
                order.total_weight = instance.cell(line,'D').to_f
                order.pingan_ordertime = instance.cell(line,'E')
                order.customer_unit = instance.cell(line,'F')
                order.customer_name = instance.cell(line,'G')
                order.customer_address = instance.cell(line,'H')
                order.customer_postcode = instance.cell(line,'I').to_s.split('.0')[0]
                order.province = instance.cell(line,'J')
                order.city = instance.cell(line,'K')
                order.county = instance.cell(line,'L')
                order.customer_tel = instance.cell(line,'M').to_s.split('.0')[0]
                order.customer_phone = instance.cell(line,'N').to_s.split('.0')[0]
                order.save
              end

              line = line+1
            end
 
            instance.default_sheet = instance.sheets.second
            dline = 2
            dline.upto(instance.last_row) do |dline|

              batch_no = to_string(instance.cell(dline,'H'))
              
              if batch_no.blank?
                business_order_id = to_string(instance.cell(dline,'A'))
                if exist_in(sheet1_error,business_order_id)
                  sheet2_error << instance.row(dline)
                  next
                end
                if business_order_id.blank?
                  txt = "缺少外部订单号"
                  sheet2_error << (instance.row(dline) << txt)
                  next
                  # raise "导入文件第二页第" + dline.to_s + "行数据, 缺少外部订单号，导入失败"
                end
                
                business_trans_no = to_string(instance.cell(line,'B'))
                if !business_trans_no.blank?
                  if !business_trans_no.eql?business_order_id
                    business_order_id = business_trans_no
                  end 
                end

                business_name = instance.cell(dline,'G')
                if business_name.blank?
                  txt = "缺少商户名称"
                  sheet1_error = order_add(sheet1_error,0,business_order_id,instance,nil)
                  sheet2_error = detail_add(sheet2_error,7,dline,instance,txt)
                  next
                  # raise "导入文件第二页第" + dline.to_s + "行数据, 缺少商户名称，导入失败"
                end
                business_id = Business.accessible_by(current_ability).find_by(name: business_name).id

                dorder = Order.accessible_by(current_ability).find_by  business_order_id: business_order_id, business_id: business_id 
              else
                if exist_in_batchno(sheet1_error,batch_no)
                  sheet2_error << instance.row(dline)
                  next
                end
                dorder = Order.accessible_by(current_ability).find_by batch_no: batch_no
              end
              
              if dorder.blank?
                txt = "详单对应订单不存在"
                sheet1_error = order_add(sheet1_error,15,batch_no,instance,txt)
                sheet2_error = detail_add(sheet2_error,7,dline,instance,txt)
                next
                # raise "导入文件第二页第" + dline.to_s + "行数据, 详单对应订单不存在，导入失败"
              end

              dorder_id = dorder.id.to_s
              # dorder_total_amount = dorder.order_details.sum(:amount)
              dorder_business_id = dorder.business_id

              if dorder.status.eql? "waiting" or dorder.status.eql? "printed"

                #供应商编号
                if !instance.cell(dline,'D').blank?
                  supplier_no = instance.cell(dline,'D').to_s.split('.0')[0]
                  supplier = Supplier.accessible_by(current_ability).find_by(no: supplier_no)
                end
   
                #SKU/第三方编码/69码
                sku_extcode_69code = to_string(instance.cell(dline,'C'))
                if !sku_extcode_69code.blank?
                  #先考虑为sku
                  specification = Specification.accessible_by(current_ability).find_by sku: sku_extcode_69code
                  #不是sku，考虑为第三方编码
                  if specification.blank?
                    relationship = Relationship.accessible_by(current_ability).find_by("business_id = ? and external_code = ?", "#{dorder_business_id}","#{sku_extcode_69code}")
                    #不是第三方编码，考虑为69码
                    if relationship.blank?
                      if !supplier.blank?
                        relationship = Relationship.accessible_by(current_ability).includes(:specification).find_by("specifications.sixnine_code=? and relationships.business_id = ? and relationships.supplier_id=?","#{sku_extcode_69code}","#{dorder_business_id}","#{supplier.id}")
                        
                      else
                        txt = "69码找不到供应商"
                        sheet1_error = order_add(sheet1_error,15,batch_no,instance,txt)
                        sheet2_error = detail_add(sheet2_error,7,dline,instance,txt)
                        next
                        # raise "导入文件第二页第" + dline.to_s + "行数据, 69码找不到供应商，导入失败"
                      end
                    end
                    
                    if !relationship.blank?
                      specification = relationship.specification
                      supplier = relationship.supplier
                    else
                      txt = "找不到对应关系"
                      sheet1_error = order_add(sheet1_error,15,batch_no,instance,txt)
                      sheet2_error = detail_add(sheet2_error,7,dline,instance,txt)
                      next
                      # raise "导入文件第二页第" + dline.to_s + "行数据, 找不到对应关系，导入失败"
                    end
                  else
                    if supplier.blank?
                      txt = "sku找不到供应商"
                      sheet1_error = order_add(sheet1_error,15,batch_no,instance,txt)
                      sheet2_error = detail_add(sheet2_error,7,dline,instance,txt)
                      next
                      # raise "导入文件第二页第" + dline.to_s + "行数据, sku找不到供应商，导入失败"
                    else
                      relationship = Relationship.accessible_by(current_ability).find_by("specification_id = ? and supplier_id = ?", "#{specification.id}","#{supplier.id}")
                      if relationship.blank?
                        txt = "sku找不到对应关系"
                        sheet1_error = order_add(sheet1_error,15,batch_no,instance,txt)
                        sheet2_error = detail_add(sheet2_error,7,dline,instance,txt)
                        next
                        # raise "导入文件第二页第" + dline.to_s + "行数据, sku找不到对应关系，导入失败"
                      end
                    end
                  end
                else
                  txt = "缺少sku/第三方编码/69码"
                  sheet1_error = order_add(sheet1_error,15,batch_no,instance,txt)
                  sheet2_error = detail_add(sheet2_error,7,dline,instance,txt)
                  next
                  # raise "导入文件第二页第" + dline.to_s + "行数据, 缺少sku/第三方编码/69码，导入失败"
                end

                amount = instance.cell(dline,'E').to_s.split('.0')[0]
                if amount.blank?
                  txt = "缺少数量"
                  sheet1_error = order_add(sheet1_error,15,batch_no,instance,txt)
                  sheet2_error = detail_add(sheet2_error,7,dline,instance,txt)
                  next
                  # raise "导入文件第二页第" + dline.to_s + "行数据, 缺少数量，导入失败"
                end

                ori_order_detail = OrderDetail.accessible_by(current_ability).find_by('supplier_id = ? and specification_id = ? and order_id = ?',"#{supplier.id}","#{specification.id}","#{dorder_id}")
                if ori_order_detail.blank?
                  next
                else
                  order_detail_id = ori_order_detail.id
                  ori_detail_amount = ori_order_detail.amount
                  if amount.to_i == 0
                    OrderDetail.destroy(order_detail_id)
                      # dorder_total_amount = dorder_total_amount - ori_detail_amount
                    # Order.update(dorder_id,total_amount: dorder_total_amount)
                  elsif amount.to_i > 0
                    OrderDetail.update(order_detail_id,amount: amount.to_i)

                    # dorder_total_amount = dorder_total_amount - ori_detail_amount + amount.to_i
                    # Order.update(dorder_id,total_amount: dorder_total_amount)
                  else
                    txt = "订单明细数量不能负数"
                    sheet1_error = order_add(sheet1_error,15,batch_no,instance,txt)
                    sheet2_error = detail_add(sheet2_error,7,dline,instance,txt)
                    next
                    # raise "导入文件第二页第" + dline.to_s + "行数据, 订单明细数量不能负数，导入失败"
                  end
                end
              end
            end
            redeal_with_errororder(sheet1_error,2)
            if !sheet1_error.blank? || !sheet2_error.blank?
              flash_message << "有部分订单导入失败！"
            end
            flash[:notice] = flash_message
            respond_to do |format|
              format.xls {   
                if !sheet1_error.blank? && !sheet2_error.blank?
                  send_data(exporterrororders_xls_content_for(sheet1_error,sheet2_error),  
                    :type => "text/excel;charset=utf-8; header=present",  
                    :filename => "Error_Orders_#{Time.now.strftime("%Y%m%d")}.xls")  
                else
                  redirect_to :action => 'findprintindex'
                end
              }
            end
          # rescue Exception => e
          #   Rails.logger.error e.backtrace
          #   flash[:alert] = e.message
          #   raise ActiveRecord::Rollback
          # end
        # end
      end   
    end
  end

  def exportorders()
    # x = params[:ids].split(",")
    # @orders = []
    # until x.blank? do
    #   @orders += Order.where(id: x.pop(1000), status: ["waiting","printed"])
    # end
    if !@@orders_export.blank?
      orders = @@orders_export.where status: ["waiting","printed"]
    end
      
    if orders.nil?
      flash[:alert] = "无订单"
      redirect_to :action => 'findprintindex'
    else
      checkbox_all = params[:checkbox][:all]
      if checkbox_all.eql? '0'
        respond_to do |format|
          format.xls {   
            send_data(exportorders_xls_content_for(find_has_stock(orders,false)),  
                :type => "text/excel;charset=utf-8; header=present",  
                :filename => "Orders_#{current_storage.no}_#{Time.now.to_i}.xls")  
          }  
        end
      else
        has_stock_orders = find_has_stock(orders,false)
        ordid = []
        if !has_stock_orders.blank?
          has_stock_orders.each do |o|
           ordid << o.id
          end
       
          respond_to do |format|
            format.xls {   
              send_data(exportorders_xls_content_for(orders.where.not(id: ordid)),  
                :type => "text/excel;charset=utf-8; header=present",  
                :filename => "Orders_#{current_storage.no}_#{Time.now.to_i}.xls")  
              # send_data(exportorders_xls_content_for(orders.where.not(id: find_has_stock(orders,false).ids)),:type => "text/excel;charset=utf-8; header=present", :filename => "Orders_#{Time.now.strftime("%Y%m%d")}.xls") 
            }  
          end
        end
      end
    end
  end

  # 订单查询导出
  def export()
    # x = params[:ids].split(",")
    
    # @orders = []
    # until x.blank? do
    #   @orders += Order.where(id: x.pop(1000))
    # end
    
    if @@orders_query_export.blank?
      flash[:alert] = "无订单"
      redirect_to :action => 'index'
    else
      respond_to do |format|
        format.xls {   
          send_data(exportorders_xls_content_for(@@orders_query_export), :type => "text/excel;charset=utf-8; header=present", :filename => "Orders_#{current_storage.no}_#{Time.now.to_i}.xls")  
        }  
      end
    end

  end

  def b2csplitorder
      @oi=@order.id
      @or_details_hash = @order.order_details.includes(:order).group(:specification_id, :supplier_id, :business_id, :storage_id).sum(:amount)
      ors = @order.children
      @scanall = OrderDetail.where(order_id: ors).includes(:order).group(:specification_id, :supplier_id, :business_id, :storage_id).sum(:amount)
      @dtl_cnt = @or_details_hash.length
      @act_cnt = 0
  end

  def b2cfind69code

    @scanspecification = Specification.where("sixnine_code = ?",params[:sixninecode]).first

    if @scanspecification.nil?
       @curr_sp=0
       @curr_sixnine=0
       @curr_der=1
    else
       @order=Order.find(params[:keyco])
       si = @order.order_details.select(:specification_id)
       sncodes=Specification.where(id: si).where("sixnine_code = ?",params[:sixninecode])
       if sncodes.blank?
        @curr_der=1
       else
        @curr_der=0
       end
       @curr_sp=@scanspecification.id
       @curr_sixnine=@scanspecification.sixnine_code
    end

    respond_to do |format|
      format.js 
    end
  end

  def b2csplitanorder
    @porder = Order.find(params[:keyco])
    parentorder = @porder
    ods = parentorder.order_details
    hasselect = false
    @order_details=nil
    @order=nil
    ods.each do |od|
      curr_specification = Specification.find(od.specification_id)
      sellabal = "b2cscancuram_" + curr_specification.sixnine_code
      if Integer(params[sellabal.to_sym]) > 0
        hasselect = hasselect || true
      else
        hasselect = hasselect || false
      end
    end
    if hasselect
      childorder = parentorder.children.create(order_type: "b2c",customer_name: parentorder.customer_name,transport_type: parentorder.transport_type,status: 'waiting',business_id: parentorder.business_id,unit_id: parentorder.unit_id,storage_id: parentorder.storage_id,keyclientorder_id: parentorder.keyclientorder_id,is_split: true,customer_name: parentorder.customer_name,customer_unit: parentorder.customer_unit,customer_tel: parentorder.customer_tel,customer_phone: parentorder.customer_phone,customer_address: parentorder.customer_address,customer_postcode: parentorder.customer_postcode,province: parentorder.province,city: parentorder.city,county: parentorder.county, business_order_id: parentorder.business_order_id)
      ods.each do |od|
        curr_specification = Specification.find(od.specification_id)
        scanlabal = "b2cscancuram_" + curr_specification.sixnine_code
        if Integer(params[scanlabal.to_sym]) > 0
          childorder.order_details.create(name: od.name,specification_id: od.specification_id,amount: params[scanlabal.to_sym],batch_no: od.batch_no,supplier_id: od.supplier_id)
        end
      end

      @porder.update(status: 'spliting')
      #binding.pry
      @order_details = childorder.order_details
      @order = childorder
    end

    respond_to do |format|
      format.js 
    end
  end

  def b2csettrackingnumber
    @curr_or = Order.find(params[:split_order])
    if !params[:split_tracking_num].nil?
      @curr_or.update_attribute(:tracking_number,params[:split_tracking_num])
    end

    podam=Order.find(@curr_or.parent.try(:id)).order_details.sum(:amount)
    cos=Order.find(@curr_or.parent.try(:id)).children
    codam = 0
    cos.each do |co|
      codam = codam + co.order_details.sum(:amount)
    end
    if podam == codam
      @curr_or.parent.update(status: 'splited')
    end

    # @curr_or.b2bsetsplitstatus
    respond_to do |format|
      format.js 
    end
  end


  # def query_order_report
  #   @order_hash = {}
  #   @orders = Order.all
  #   status = ["waiting","checked","packed","delivering","delivered","returned"]
    
  #   if params[:query_order_start_date].blank? or params[:query_order_start_date]["query_order_start_date"].blank?
  #     start_date = Time.now.beginning_of_week
  #     if RailsEnv.is_oracle?
  #       start_date = to_char(DateTime.parse(start_date.to_s),'yyyymmdd')
  #     else
  #       start_date=DateTime.parse(start_date.to_s).strftime('%Y-%m-%d').to_s
  #     end
  #     @orders=@orders.accessible_by(current_ability).where("orders.created_at >= ? and orders.status in (?)", start_date,status)
  #   else 
  #     start_date = Date.civil(params[:query_order_start_date]["query_order_start_date"].split(/-|\//)[0].to_i, params[:query_order_start_date]["query_order_start_date"].split(/-|\//)[1].to_i, params[:query_order_start_date]["query_order_start_date"].split(/-|\//)[2].to_i)
  #     @orders=@orders.accessible_by(current_ability).where("orders.created_at >= ? and orders.status in (?)", start_date,status)
  #   end
  #   if params[:query_order_end_date].blank? or params[:query_order_end_date]["query_order_end_date"].blank?
  #     end_date = Time.now.end_of_week
  #     if RailsEnv.is_oracle?
  #       end_date = to_char(DateTime.parse(end_date.to_s),'yyyymmdd')
  #     else
  #       end_date=DateTime.parse(end_date.to_s).strftime('%Y-%m-%d').to_s
  #     end
  #     end_date = Date.civil(end_date.split(/-|\//)[0].to_i, end_date.split(/-|\//)[1].to_i, end_date.split(/-|\//)[2].to_i)
  #     @orders=@orders.accessible_by(current_ability).where("orders.created_at <= ? and orders.status in (?)", (end_date+1),status)
  #   else
  #     end_date = Date.civil(params[:query_order_end_date]["query_order_end_date"].split(/-|\//)[0].to_i, params[:query_order_end_date]["query_order_end_date"].split(/-|\//)[1].to_i, params[:query_order_end_date]["query_order_end_date"].split(/-|\//)[2].to_i)
  #     @orders=@orders.accessible_by(current_ability).where("orders.created_at <= ? and orders.status in (?)", (end_date+1),status)

  #   end


  #   @order_hash = @orders.group(:business_id).group(:transport_type).order(:business_id).order(:transport_type).count


  # end

  def orders_import
    @ids = []
    unless request.get?
      if file = upload_pingan(params[:file]['file'])
        instance=nil
        if file.include?('.xlsx')
          instance= Roo::Excelx.new(file)
        elsif file.include?('.xls')
          instance= Roo::Excel.new(file)
        elsif file.include?('.csv')
          instance= Roo::CSV.new(file)
        end
        sheet1_error = []
        sheet2_error = []
        instance.default_sheet = instance.sheets.first
        flash_message = "导入成功!"
        is_shortage = ""
        ords = []
        status = "waiting"
        koid=""        

        #商户
        business_id = params[:business_select]
        if params[:business_select].blank?
          koid = getKeycOrderID()
          import_type=back
        else
          import_type=standard
        end
        #从第二行开始一直读取，直到空行 
        line = 2
        line.upto(instance.last_row) do |line|
          batch_no = to_string(instance.cell(line,'Q'))
          if batch_no.blank?
            business_order_id = to_string(instance.cell(line,'A'))
            if business_order_id.blank?
              txt = "缺少外部订单号"
              sheet1_error << (instance.row(line) << txt)
              next
            else
              business_trans_no = to_string(instance.cell(line,'R'))
              if !business_trans_no.blank?
                if !business_trans_no.eql?business_order_id
                  business_order_id = business_trans_no
                end 
              end
              if business_id.blank?
                business_no = instance.cell(line,'O')
                if business_no.blank?
                  txt = "缺少商户编号"
                  sheet1_error << (instance.row(line) << txt)
                  next
                else
                  business = Business.accessible_by(current_ability).find_by(no: business_no)
                end
              else
                business = Business.accessible_by(current_ability).find_by(id: business_id)
              end

              ori_order = Order.accessible_by(current_ability).find_by  business_order_id: business_order_id, business_id:business.id
                
            end
          else
            ori_order = Order.accessible_by(current_ability).find_by  batch_no: batch_no
            if ori_order.blank?
              txt = "批次号错误"
              sheet1_error << (instance.row(line) << txt)
              next
            end
          end
          
          transport_type = to_string(instance.cell(line,'C'))
          tracking_number = to_string(instance.cell(line,'B'))
          if transport_single(transport_type,tracking_number)
            txt = "物流单号和物流供应商不能只填一个"
            sheet1_error << (instance.row(line) << txt)
            next
          end
          if !transport_type.blank?
            transport_type = to_transport_type(transport_type)
            if transport_type.blank?
              txt = "物流供应商错误"
              sheet1_error << (instance.row(line) << txt)
              next
            else
              if !tracking_number.blank?
                status = "printed"
                @keyclientorder = Keyclientorder.find_by id:koid
              else
                tracking_number = nil
              end
            end
          else
            transport_type = nil
          end

          if ori_order.blank? 
            order = Order.create! order_type: 'b2c',business_order_id: business_order_id, tracking_number: tracking_number, transport_type: transport_type,  total_weight: instance.cell(line,'D').to_f, pingan_ordertime: instance.cell(line,'E'), customer_unit: instance.cell(line,'F'), customer_name: instance.cell(line,'G'), customer_address: instance.cell(line,'H'), customer_postcode: to_string(instance.cell(line,'I')), 
              province: instance.cell(line,'J'), 
              city: instance.cell(line,'K'), 
              county: instance.cell(line,'L'), customer_tel: to_string(instance.cell(line,'M')),
              customer_phone: to_string(instance.cell(line,'N')), 
              business: business, 
              unit_id: current_user.unit.id, 
              storage_id: current_storage.id, 
              status: status,
              keyclientorder: @keyclientorder,
              user_id: current_user.id

            ords[0] = order
            if find_has_stock(ords,false).blank?
              is_shortage = "yes"
            else
              is_shortage = "no"
            end
            Order.update(order.id,is_shortage: is_shortage)
                      
            @ids << order.id
          else
            order_status = ori_order.status
            if order_status.eql?"waiting" or order_status.eql? "printed"
              order_id = ori_order.id.to_s

              order = Order.update(order_id,tracking_number:tracking_number,transport_type:transport_type,total_weight:instance.cell(line,'D').to_f,pingan_ordertime:instance.cell(line,'E'),customer_unit:instance.cell(line,'F'),customer_name:instance.cell(line,'G'),customer_address:instance.cell(line,'H'),customer_postcode:to_string(instance.cell(line,'I')),province:instance.cell(line,'J'),city:instance.cell(line,'K'),county:instance.cell(line,'L'),customer_tel:to_string(instance.cell(line,'M')),customer_phone:to_string(instance.cell(line,'N')),
                status: status,keyclientorder: @keyclientorder,user_id: current_user.id)
            
              ords[0] = order
              if find_has_stock(ords,false).blank?
                is_shortage = "yes"
              else
                is_shortage = "no"
              end
              Order.update(order.id,is_shortage: is_shortage)
                      
              @ids << order_id
            else
              txt = "订单已处理"
              sheet1_error << (instance.row(line) << txt)
              next
            end
          end          
          line = line+1
        end
      
        #读取订单明细     
        instance.default_sheet = instance.sheets.second
        dline = 2
        dline.upto(instance.last_row) do |dline|
          #供应商编号
          supplier_no = to_string(instance.cell(dline,'D'))
          if !supplier_no.blank?
            supplier = Supplier.accessible_by(current_ability).find_by(no: supplier_no)
          end
          
          #批次号
          batch_no = to_string(instance.cell(dline,'I'))
          if batch_no.blank?
            #外部订单号
            business_order_id = to_string(instance.cell(dline,'A'))
            if exist_in(sheet1_error,business_order_id)
              sheet2_error << instance.row(dline)
              next
            end

            if business_order_id.blank?
              txt = "缺少外部订单号"
              sheet2_error << (instance.row(dline) << txt)
              next
            end

            #子订单号
            sub_order_id = to_string(instance.cell(dline,'B'))
            if !sub_order_id.blank?
              if !sub_order_id.eql?business_order_id
                business_order_id = sub_order_id
              end 
            end
          
            
            if business_id.blank?
              business_no = to_string(instance.cell(dline,'G'))
              if business_no.blank?
                txt = "缺少商户编号"
                sheet1_error = order_add(sheet1_error,0,business_order_id,instance,nil)
                sheet2_error = detail_add(sheet2_error,7,dline,instance,txt)
                next
              else
                business = Business.accessible_by(current_ability).find_by(no: business_no)
              end
            else
              business = Business.accessible_by(current_ability).find_by(id: business_id)
            end
            #根据外部订单号找到对应订单
            dorder = Order.accessible_by(current_ability).find_by business_order_id: business_order_id, business_id: business.id

            if dorder.blank?
              txt = "详单对应订单不存在"
              sheet1_error = order_add(sheet1_error,0,business_order_id,instance,txt)
              sheet2_error = detail_add(sheet2_error,0,dline,instance,txt)
              next
            end
        
          else
            if exist_in_batchno(sheet1_error,batch_no)
              sheet2_error << instance.row(dline)
              next
            end
            dorder = Order.accessible_by(current_ability).find_by batch_no: batch_no
            if dorder.blank?
              txt = "批次号错误"
              sheet2_error << (instance.row(dline) << txt)
              next
            end
            business=dorder.business

          end

          
          #SKU/第三方编码/69码
          sku_extcode_69code = to_string(instance.cell(dline,'C'))

          if !sku_extcode_69code.blank?
            #先考虑为sku
            specification = Specification.accessible_by(current_ability).find_by sku: sku_extcode_69code
            #不是sku，考虑为第三方编码
            if specification.blank?
              relationship = Relationship.accessible_by(current_ability).find_by("business_id = ? and external_code = ?", business.id,"#{sku_extcode_69code}")
              #不是第三方编码，考虑为69码
              if relationship.blank?
                if !supplier.blank?
                  relationship = Relationship.includes(:specification).accessible_by(current_ability).find_by("specifications.sixnine_code=? and relationships.business_id = ? and relationships.supplier_id=?","#{sku_extcode_69code}","#{business.id}","#{supplier.id}")
                else
                  txt = "69码找不到供应商"
                  sheet1_error = order_add(sheet1_error,0,business_order_id,instance,txt)
                  sheet2_error = detail_add(sheet2_error,0,dline,instance,txt)
                  next
                end
              end
                  
              if !relationship.blank?
                specification = relationship.specification
                supplier = relationship.supplier
              else
                txt = "找不到对应关系"
                sheet1_error = order_add(sheet1_error,0,business_order_id,instance,txt)
                sheet2_error = detail_add(sheet2_error,0,dline,instance,txt)
                next
              end
            else
              if supplier.blank?
                txt = "sku找不到供应商"
                sheet1_error = order_add(sheet1_error,0,business_order_id,instance,txt)
                sheet2_error = detail_add(sheet2_error,0,dline,instance,txt)
                next
              else
                relationship = Relationship.accessible_by(current_ability).find_by("specification_id = ? and supplier_id = ?", "#{specification.id}","#{supplier.id}")
                if relationship.blank?
                  txt = "sku找不到对应关系"
                  sheet1_error = order_add(sheet1_error,0,business_order_id,instance,txt)
                  sheet2_error = detail_add(sheet2_error,0,dline,instance,txt)
                  next
                end
              end
            end
          else
            txt = "缺少sku/第三方编码/69码"
            sheet1_error = order_add(sheet1_error,0,business_order_id,instance,txt)
            sheet2_error = detail_add(sheet2_error,0,dline,instance,txt)
            next
          end
          
          #数量
          temp_amount = to_string(instance.cell(dline,'E'))
          if temp_amount.blank?
            txt = "缺少数量"
            sheet1_error = order_add(sheet1_error,0,business_order_id,instance,txt)
            sheet2_error = detail_add(sheet2_error,0,dline,instance,txt)
            next
          end

          amount = find_in_instance(instance,dline,business_order_id,sku_extcode_69code,supplier_no,sub_order_id,temp_amount)
         
          dorder_id = dorder.id.to_s
          dorder_status = dorder.status
          if dorder.status.eql? "waiting" or dorder.status.eql? "printed"
            #取得原有订单明细记录
            ori_order_detail = OrderDetail.accessible_by(current_ability).where('supplier_id = ? and specification_id = ? and order_id = ?',"#{supplier.id}","#{specification.id}","#{dorder_id}")
            business_deliver_no = ""
            business_trans_no = ""
            if !sub_order_id.blank?
              if to_string(instance.cell(dline,'A')).eql?sub_order_id
                business_deliver_no = sub_order_id
                business_trans_no = dorder.business_order_id

                if !ori_order_detail.blank?
                ori_order_detail = ori_order_detail.where(business_deliver_no:sub_order_id)
                end
              else
                business_deliver_no = nil
                business_trans_no = to_string(instance.cell(dline,'A'))
              end
            end     

            #原来没有，创建
            if ori_order_detail.blank? 
              #数量小等于0，跳过
              if amount.to_i <=0
                 next
              #数量大于0，创建，同时对应订单数量增加
              else 
                OrderDetail.create! name: specification.name,batch_no: batch_no, specification: specification, amount: amount.to_i, supplier: supplier,business_deliver_no: business_deliver_no, order: dorder
                Order.update(dorder_id,business_trans_no: business_trans_no) 
              end
            #原来有，更新原记录
            else
              order_detail_id = ori_order_detail.first.id

              #数量为0，删除该订单明细
              if amount.to_i == 0
                OrderDetail.destroy(order_detail_id)
              #数量大于0，更新该订单明细
              elsif amount.to_i > 0
                OrderDetail.update(order_detail_id,amount: amount.to_i,business_deliver_no: business_deliver_no)
                Order.update(dorder_id,business_trans_no: business_trans_no)
              #数量小于0，报错
              else
                txt = "订单明细数量不能负数"
                sheet1_error = order_add(sheet1_error,0,business_order_id,instance,txt)
                sheet2_error = detail_add(sheet2_error,0,dline,instance,txt)
                next
              end
            end 
          else
            txt = "只有待处理状态的订单才能重复导入"
            sheet1_error = order_add(sheet1_error,0,business_order_id,instance,txt)
            sheet2_error = detail_add(sheet2_error,0,dline,instance,txt)
            next
          end
        end
        if !params[:business_select].blank?
          redeal_with_errororder(sheet1_error,1)
        else
          redeal_with_errororder(sheet1_error,2)
        end
        if !sheet1_error.blank? || !sheet2_error.blank?
          flash_message << "有部分订单导入失败！"
        end
        flash[:notice] = flash_message

        respond_to do |format|
          format.xls {   
            if !sheet1_error.blank? && !sheet2_error.blank?
              send_data(exporterrororders_xls_content_for(sheet1_error,sheet2_error),  
              :type => "text/excel;charset=utf-8; header=present",  
              :filename => "Error_Orders_#{Time.now.strftime("%Y%m%d")}.xls")  
            else
              redirect_to :action => 'findprintindex'
            end
          }
        end
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

=begin
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
=end

def exportorders_xls_content_for(objs)  
    
    xls_report = StringIO.new  
    book = Spreadsheet::Workbook.new  
    sheet1 = book.create_worksheet :name => "Orders"  

    blue = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 10  
    sheet1.row(0).default_format = blue  

    sheet1.row(0).concat %w{订单号(外部) 物流单号 物流供应商 重量(g) 下单时间 客户单位 收件客户 收件详细地址 收货邮编 收件省 收件市 收件县区 收件人联系电话 收货手机 商户编号 商户名称 订单流水号 子订单号 状态 商品信息}  
    count_row = 1
    objs.each do |obj|
      if obj.is_shortage.eql? 'yes'
        red = Spreadsheet::Format.new :color => :red
        sheet1.row(count_row).default_format = red  
      end
      transport_type = obj.transport_type_name
      
      if obj.business_trans_no.blank?
        # 原始订单
        business_order_id = obj.business_order_id
        business_trans_no = ""
      else 
        if obj.business_trans_no.eql? obj.business_order_id
          # 未拆单处理归并订单
          business_order_id = obj.business_order_id
          business_trans_no = obj.business_trans_no
        else
          # 拆单处理归并订单
          business_order_id = obj.business_trans_no
          business_trans_no = obj.business_order_id
        end
      end

      all_name = ""
      order_details = OrderDetail.accessible_by(current_ability).where('order_id = ?',"#{obj.id}")
      order_details.each do |order_detail|
        if !order_detail.specification.blank?
          all_name = all_name + order_detail.specification.full_title + "*" + order_detail.amount.to_s + ","
        end
      end

      sheet1[count_row,0]=business_order_id
      sheet1[count_row,1]=obj.tracking_number.to_s
      sheet1[count_row,2]=transport_type
      sheet1[count_row,3]=obj.total_weight
      sheet1[count_row,4]=obj.pingan_ordertime
      sheet1[count_row,5]=obj.customer_unit
      sheet1[count_row,6]=obj.customer_name
      sheet1[count_row,7]=obj.customer_address
      sheet1[count_row,8]=obj.customer_postcode
      sheet1[count_row,9]=obj. province
      sheet1[count_row,10]=obj.city
      sheet1[count_row,11]=obj.county
      sheet1[count_row,12]=obj.customer_tel
      sheet1[count_row,13]=obj.customer_phone
      sheet1[count_row,14]=obj.business.no
      sheet1[count_row,15]=obj.business.name
      sheet1[count_row,16]=obj.batch_no
      sheet1[count_row,17]=business_trans_no
      sheet1[count_row,18]=obj.status_name
      sheet1[count_row,19]=all_name[0,all_name.size-1]
    
      count_row += 1
    end  

    sheet2 = book.create_worksheet :name => "OrderDetails"
    detail_row = 0
    sheet2.row(detail_row).default_format = blue 
    sheet2.row(detail_row).concat %w{订单号(外部) 子订单号 SKU/第三方编码/69码 供应商编号 数量 商品名称 商户编号 商户名称 订单流水号}
    detail_row = detail_row + 1
    objs.each do |obj|
      obj_id = obj.id
      business_id = obj.business_id
      order_details = OrderDetail.accessible_by(current_ability).where('order_id = ?',"#{obj_id}")
      order_details.each do |order_detail|
        if order_detail.is_shortage.eql? 'yes'
          red = Spreadsheet::Format.new :color => :red
          sheet2.row(detail_row).default_format = red  
        end
        supplier_id = order_detail.supplier_id
        supplier_no = Supplier.accessible_by(current_ability).find_by('id = ?',"#{supplier_id}").no

        specification_id = order_detail.specification_id
        specification = Specification.accessible_by(current_ability).find(specification_id)
        
        relationship = Relationship.accessible_by(current_ability).find_by(business_id: business_id, supplier_id: supplier_id, specification_id: specification_id)

        if relationship.blank?
          external_code = ""
        else
          external_code = relationship.external_code
        end

        if obj.business_trans_no.blank?
          # 原始订单
          business_order_id = obj.business_order_id
          sub_order_id = ""
        else
          if obj.business_trans_no.eql? obj.business_order_id
            # 未拆单处理归并订单
            business_order_id = obj.business_order_id
            sub_order_id = order_detail.business_deliver_no
          else
            # 拆单处理归并订单
            business_order_id = obj.business_trans_no
            sub_order_id = obj.business_order_id
          end
        end

        sku_extcode_69code = specification.sku
        sku_extcode_69code ||= external_code
        sku_extcode_69code ||= specification.sixnine_code

        sheet2[detail_row,0]=business_order_id
        sheet2[detail_row,1]=sub_order_id
        sheet2[detail_row,2]=sku_extcode_69code
        sheet2[detail_row,3]=supplier_no
        sheet2[detail_row,4]=order_detail.amount
        sheet2[detail_row,5]=specification.full_title
        sheet2[detail_row,6]=obj.business.no
        sheet2[detail_row,7]=obj.business.name
        sheet2[detail_row,8]=order_detail.order.batch_no
        
        detail_row += 1
      end
    end

    book.write xls_report  
    xls_report.string  
  end

  def getTrackingNumber(transport_type, tracking_number, line=nil)
    return_no = []
    case transport_type
    when "tcsd","同城速递"
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
    when "gnxb","国内小包"
      case tracking_number.size
      when 13
        return_no << tracking_number[0,2] << tracking_number[2,11] << ""
      else
        raise (line.blank?? "":"导入文件第"+line.to_s+"行,") + "国内小包邮件编号格式错误,导入失败"
      end
    when "ems","EMS"
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
    when "ttkd"
      case tracking_number.size
      when 13
        return_no << tracking_number[0,2] << tracking_number[2,8] << tracking_number[11,2]
      else
        raise (line.blank?? "":"导入文件第"+line.to_s+"行,") + "天天快递邮件编号格式错误,导入失败"
      end
    when "bsht"
      case tracking_number.size
      when 13
        return_no << tracking_number[0,2] << tracking_number[2,8] << tracking_number[11,2]
      else
        raise (line.blank?? "":"导入文件第"+line.to_s+"行,") + "百世汇通邮件编号格式错误,导入失败"
      end
    when "qt"
      case tracking_number.size
      when 13
        return_no << tracking_number[0,2] << tracking_number[2,8] << tracking_number[11,2]
      else
        raise (line.blank?? "":"导入文件第"+line.to_s+"行,") + "其他承运商邮件编号格式错误,导入失败"
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
    # batch_no = time.year.to_s+time.month.to_s.rjust(2,'0')+time.day.to_s.rjust(2,'0')+Keyclientorder.count.to_s.rjust(5,'0')
    keycorder = Keyclientorder.create(keyclient_name: "面单信息回馈 "+DateTime.parse(Time.now.to_s).strftime('%Y-%m-%d %H:%M:%S').to_s,unit_id: current_user.unit_id,storage_id: current_storage.id,user: current_user,status: "printed")
    return keycorder.id
  end

  def add_text(index,content)
    index == 0? content:(","+content)
  end

  def to_string(text)
    if text.is_a? Float
      return text.to_s.split('.0')[0]
    else
      return text
    end
  end

  def exist_in(arrays,id)
    arrays.each do |x|
      if to_string(x[0]).eql? id
        return true
      else
        next
      end
    end
    return false
  end

  def exist_in_batchno(arrays,id)
    arrays.each do |x|
      if to_string(x[16]).eql? id
        return true
      else
        next
      end
    end
    return false
  end

  def order_add(target,index,id,instance,txt=nil)
    if !target.find{|x| to_string(x[index]) == id}.blank?
      return target
    end
    instance.default_sheet = instance.sheets.first
    2.upto(instance.last_row) do |line|
      if to_string(instance.row(line)[index]).eql? id
        target << (instance.row(line) << txt)
        return target
      end
    end
    return target
  end

  def detail_add(target,index,dline,instance,txt=nil)
    instance.default_sheet = instance.sheets.second
    # 2.upto(instance.last_row) do |line|
      index_content = 15
      if index == 0
        index_content = 0
      end
      # if to_string(instance.row(line)[index]).eql? to_string(content[index_content])
        if target.find{|x| x == instance.row(dline)}.blank?
          target << (instance.row(dline) << txt)
        end
    #   end
    # end
    return target
  end

  def redeal_with_errororder(target,type)
    case type
    when 1
      # remove the order and details
      # different between exist order and new order
      # new order should be delete and exist order must be keep
      target.each do |x|
        business_id = to_string(x[0])
        batch_no = to_string(x[15])
        order = nil
        if !batch_no.blank?
          order = Order.accessible_by(current_ability).find_by batch_no: batch_no
        elsif !business_id.blank?
          order = Order.accessible_by(current_ability).find_by business_order_id: business_id
        end
        # skip the exist order and delete the new order
        if !order.blank? && (order.created_at == order.updated_at)
          order.order_details.delete_all
          order.delete
        end
      end
    when 2
      #  update the order status to waiting and clean transtype info
      target.each do |x|
        business_id = to_string(x[0])
        batch_no = to_string(x[15])
        order = nil
        if !batch_no.blank?
          order = Order.accessible_by(current_ability).find_by batch_no: batch_no
        else
          order = Order.accessible_by(current_ability).find_by business_order_id: business_id
        end
        if !order.blank?
          order.status = 'waiting'
          order.tracking_number = nil
          order.transport_type=nil
          order.user_id=nil
          order.keyclientorder_id=nil
          order.save
        end
      end
    end
  end

  def exporterrororders_xls_content_for(obj1,obj2)  
    
    xls_report = StringIO.new  
    book = Spreadsheet::Workbook.new  
    sheet1 = book.create_worksheet :name => "Orders"  

    blue = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 10  
    red = Spreadsheet::Format.new :color => :red
    sheet1.row(0).default_format = blue  

    sheet1.row(0).concat %w{订单号(外部) 物流单号 物流供应商 重量(g) 下单时间 客户单位 收件客户 收件详细地址 收货邮编 收件省 收件市 收件县区 收件人联系电话 收货手机 商户编号 商户名称 订单流水号 子订单号 状态 商品信息}  
    count_row = 1
    obj1.each do |obj|
      # if obj.is_shortage.eql? 'yes'
      #   red = Spreadsheet::Format.new :color => :red
      #   sheet1.row(count_row).default_format = red  
      # end
      # transport_type = obj.transport_type
      # case transport_type
      #   when "tcsd"
      #     tran_type = '同城速递'
      #   when "gnxb"
      #     tran_type = '国内小包'  
      #   when "ems"
      #     tran_type = 'EMS'
      #   when "ttkd"
      #     tran_type = '天天快递'
      #   when "bsht"
      #     tran_type = '百世汇通'
      #   when "qt"
      #     tran_type = '其他'
      # end

      # if obj.business_trans_no.blank?
      #   # 原始订单
      #   business_order_id = obj.business_order_id
      #   business_trans_no = ""
      # else 
      #   if obj.business_trans_no.eql? obj.business_order_id
      #     # 未拆单处理归并订单
      #     business_order_id = obj.business_order_id
      #     business_trans_no = obj.business_trans_no
      #   else
      #     # 拆单处理归并订单
      #     business_order_id = obj.business_trans_no
      #     business_trans_no = obj.business_order_id
      #   end
      # end

      # all_name = ""
      # order_details = OrderDetail.accessible_by(current_ability).where('order_id = ?',"#{obj.id}")
      # order_details.each do |order_detail|
      #   if !order_detail.specification.blank?
      #     all_name = all_name + order_detail.specification.all_name + "*" + order_detail.amount.to_s + ","
      #   end
      # end

      sheet1[count_row,0]=obj[0]
      sheet1[count_row,1]=obj[1]
      sheet1[count_row,2]=obj[3]
      sheet1[count_row,3]=obj[3]
      sheet1[count_row,4]=obj[4]
      sheet1[count_row,5]=obj[5]
      sheet1[count_row,6]=obj[6]
      sheet1[count_row,7]=obj[7]
      sheet1[count_row,8]=obj[8]
      sheet1[count_row,9]=obj[9]
      sheet1[count_row,10]=obj[10]
      sheet1[count_row,11]=obj[11]
      sheet1[count_row,12]=obj[12]
      sheet1[count_row,13]=obj[13]
      sheet1[count_row,14]=obj[14]
      sheet1[count_row,15]=obj[15]
      sheet1[count_row,16]=obj[16]
      sheet1[count_row,17]=obj[17]
      sheet1[count_row,18]=obj[18]
      sheet1[count_row,19]=obj[19]
      sheet1[count_row,20]=obj[20]

      count_row += 1
    end  

    sheet2 = book.create_worksheet :name => "OrderDetails"
    detail_row = 0
    sheet2.row(detail_row).default_format = blue 
    sheet2.row(detail_row).concat %w{订单号(外部) 子订单号 SKU/第三方编码/69码 供应商编号 数量 商品名称 商户编号 商户名称 订单流水号}
    detail_row = detail_row + 1
    obj2.each do |obj|
      # obj_id = obj.id
      # business_id = obj.business_id
      # order_details = OrderDetail.accessible_by(current_ability).where('order_id = ?',"#{obj_id}")
      # order_details.each do |order_detail|
      #   if obj.is_shortage.eql? 'yes'
      #     red = Spreadsheet::Format.new :color => :red
      #     sheet2.row(detail_row).default_format = red  
      #   end
      #   supplier_id = order_detail.supplier_id
      #   supplier_no = Supplier.accessible_by(current_ability).find_by('id = ?',"#{supplier_id}").no

      #   specification_id = order_detail.specification_id
      #   specification = Specification.accessible_by(current_ability).find(specification_id)
        
      #   relationship = Relationship.accessible_by(current_ability).find_by(business_id: business_id, supplier_id: supplier_id, specification_id: specification_id)

      #   if relationship.blank?
      #     external_code = ""
      #   else
      #     external_code = relationship.external_code
      #   end

      #   if obj.business_trans_no.blank?
      #     # 原始订单
      #     business_order_id = obj.business_order_id
      #     sub_order_id = ""
      #   else
      #     if obj.business_trans_no.eql? obj.business_order_id
      #       # 未拆单处理归并订单
      #       business_order_id = obj.business_order_id
      #       sub_order_id = order_detail.business_deliver_no
      #     else
      #       # 拆单处理归并订单
      #       business_order_id = obj.business_trans_no
      #       sub_order_id = obj.business_order_id
      #     end
      #   end

      #   sku_extcode_69code = specification.sku
      #   sku_extcode_69code ||= external_code
      #   sku_extcode_69code ||= specification.sixnine_code

        sheet2[detail_row,0]=obj[0]
        sheet2[detail_row,1]=obj[1]
        sheet2[detail_row,2]=obj[2]
        sheet2[detail_row,3]=obj[3]
        sheet2[detail_row,4]=obj[4]
        sheet2[detail_row,5]=obj[5]
        sheet2[detail_row,6]=obj[6]
        sheet2[detail_row,7]=obj[7]
        sheet2[detail_row,8]=obj[8]
        sheet2[detail_row,9]=obj[9]
        
        detail_row += 1
      # end
    end

    book.write xls_report  
    xls_report.string  
  end

  def find_in_instance(instance,dline,business_order_id,sku_extcode_69code,supplier_no,business_deliver_no,amount)
    instance.default_sheet = instance.sheets.second
    amount=amount.to_i
    # binding.pry
    2.upto(dline-1) do |line|
      re=(to_string(instance.row(line)[0]).eql?business_order_id and to_string(instance.row(line)[2]).eql?sku_extcode_69code and to_string(instance.row(line)[3]).eql?supplier_no)
      if !business_deliver_no.blank?
        re=(re and to_string(instance.row(line)[1]).eql?business_deliver_no)
      end
      if re
        amount=amount+to_string(instance.row(line)[4]).to_i
      end
    end
    return amount
  end

  def to_transport_type(transport_type)
    case transport_type
      when "同城速递","tcsd","TCSD"
        tran_type = 'tcsd'
      when "国内小包","gnxb","GNXB"
        tran_type = 'gnxb'  
      when "EMS","ems"
        tran_type = 'ems'
      when "天天快递","ttkd","TTKD"
        tran_type = 'ttkd'
      when "百世汇通","bsht","BSHT"
        tran_type = 'bsht'
      when "其他","qt","QT"
        tran_type = 'qt'
      else
        tran_type = nil
    end
    return tran_type
  end

  def transport_single(trantype,tracknumber)
    if (!trantype.blank? and tracknumber.blank?) or (!tracknumber.blank? and trantype.blank?)
      return true
    else 
      return false
    end
  end


  
end
