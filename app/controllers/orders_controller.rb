class OrdersController < ApplicationController
  load_and_authorize_resource
  user_logs_filter only: [:orders_import], symbol: "订单导入回馈 #{DateTime.parse(Time.now.to_s).strftime('%Y-%m-%d %H:%M:%S').to_s}", ids: :ids, operation: '订单导入回馈', object: :keyclientorder, parent: :keyclientorder, import_type: :import_type
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
      find_stock(@orders, true, '0')
    
    else
      @keycorder=Keyclientorder.where(keyclient_name: "auto",user: current_user,status: "waiting").order('batch_no').first
      @orders=@keycorder.orders
      #find_has_stock(@orders)
    end
  end

  def find_stock(orders,createKeyCilentOrderFlg,type='0')
    order_details_hash = orders.unscope(:order).unscope(:includes).joins(:order_details).group(:specification_id, :supplier_id, :business_id).sum(:amount)
    orders.update_all(is_shortage: 'no')
    orders_changed = false
    order_details_hash.each do |key, sum|
      stock_sum = Stock.total_stock_in_storage(Specification.find(key[0]), key[1].blank? ? nil : Supplier.find(key[1]), Business.find(key[2]), current_storage,is_broken=false)
      if orders_changed
        sum = orders.includes(:order_details).where(is_shortage: 'no').where(order_details: {specification_id: key[0], supplier_id: key[1]}, business_id: key[2], storage_id: current_storage.id).sum(:amount)
      end
      if stock_sum < sum
        orders_changed = true
        related_orders = orders.joins(:order_details).where(order_details: {specification_id: key[0], supplier_id: key[1]}, business_id: key[2], storage_id: current_storage.id)
        limit = sum - stock_sum
        offset_orders = related_orders.offset(related_orders.count - limit).readonly(false)
        offset_sum = offset_orders.includes(:order_details).sum(:amount)
        if offset_sum == limit
          offset_orders.update_all(is_shortage: 'yes')
        else
          offset_orders.each do |x|
            related_details = x.order_details.where(order_details: {specification_id: key[0], supplier_id: key[1]})
            tmp_sum = related_details.sum(:amount)
            x.update(is_shortage: 'yes')
            related_details.update_all(is_shortage: 'yes')
            limit = limit - tmp_sum
            if limit <= 0
              break
            end
          end
        end
        # order_array = []
        # x.each do |y|
        #   order_array << y.id
        # end
        # orders.delete_if {|item| !order_array.index(item.id).blank?}
      end
    end

    return_orders = nil

    if type.eql? '0'
      return_orders = orders.reload.where(is_shortage: 'no')
    else
      return_orders = orders.reload.where(is_shortage: 'yes')
    end

    if createKeyCilentOrderFlg
      if ordercnt > 0
        time = Time.new
        # batch_no = time.year.to_s+time.month.to_s.rjust(2,'0')+time.day.to_s.rjust(2,'0')+Keyclientorder.count.to_s.rjust(5,'0')
        @keycorder = Keyclientorder.create(keyclient_name: "auto",unit_id: current_user.unit_id,storage_id: current_storage.id,user: current_user,status: "waiting")
        return_orders.update_all(keyclientorder_id: @keycorder)

        allcnt = return_orders.includes(:order_details).where.not("order_details.specification_id" => nil, business_id: nil).group("orders.business_id", :specification_id, :supplier_id).sum(:amount)

        allcnt.each do |k,v|
          if v[1] > 0
            Keyclientorderdetail.create(keyclientorder: @keycorder,business_id: k[0],specification_id: k[1],supplier_id: k[2],amount: v)
          end
        end
      end
    end

    return return_orders.reload

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
        is_broken=true if d.defective.eql?"1"
        is_broken=false if d.defective.eql?"0"
        allamount = Stock.total_stock_in_storage(d.specification, d.supplier, o.business, current_storage,is_broken)
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
        # orders=Order.where(id: finorders)
        # orders.update_all(keyclientorder_id: @keycorder)

        allcnt.each do |k,v|
          if v[1] > 0
            Keyclientorderdetail.create(keyclientorder: @keycorder,business_id: k[0],specification_id: k[1],supplier_id: k[2],amount: v[1])
          end
        end
      end
    end
    # orders=Order.where(id: finorders)
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

  def packout
    @needpick = current_storage.need_pick
    @order_details=[]
    @curr_order=""
    @orders = Order.where("storage_id = ?", current_storage.id)
    @orders_grid=initialize_grid(@orders,
      :conditions => ['order_type = ? ',"b2c"])
  end

  def findorderout
    @needpick = current_storage.need_pick
    @ispd=1
    @_tracking_number = params[:_tracking_number]
    @tracking_number = params[:tracking_number]

    if !@_tracking_number.blank?
      @order_details = []
      @curr_order = 0

      order = Order.find(params[:orderid])
      @curr_order = order.id

      curr_dtls = nil
      order.order_details.each do |x|
        if x.desc.blank? || ! x.desc.eql?('haspacked')
          if x.specification.sixnine_code.eql?(@tracking_number) || x.relationship.barcode.eql?(@tracking_number) || x.relationship.external_code.eql?(@tracking_number)
            curr_dtls = x
            break
          end
        end
      end

      # curr_dtls_a = order.order_details.includes(:specification).where("specifications.sixnine_code = ? ",params[:tracking_number]).where(desc: nil)
      # curr_dtls_b = order.order_details.includes(:specification).where("specifications.sixnine_code = ? ",params[:tracking_number]).where.not(desc: "haspacked")

      # curr_dtls_c = curr_dtls_a + curr_dtls_b
      
      if curr_dtls.nil?
        @curr_dtl = -1
      else
        @curr_dtl = curr_dtls.id
        if curr_dtls.amount == 1
          @curod = OrderDetail.find(curr_dtls.id).update(desc: "haspacked")
        end
      end 
    else
      order = Order.where(" (tracking_number=? or barcode=?) and status=?",@tracking_number,@tracking_number,"checked").first
      if order.nil?
        @curr_order = 0
        @curr_dtl = 0
      else
        @curr_order = order.id
        @order = order
        if @order.is_printed
          @ispd=1
        else
          @ispd=0
        end
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
    if current_storage.need_pick
      @keyclientorder=@order.keyclientorder
      @keyclientorder.pickoutcheck!(@order)
    end
    @order.update_attribute(:status, "packed")
    respond_to do |format|
      format.js 
    end
  end

  def setstlogchkamt 
    if current_storage.need_pick
      @order=Order.find(params[:orderid])
      @ordtl=OrderDetail.find(params[:ordtlid])
      @relationship=Relationship.where("business_id=? and supplier_id=? and specification_id=?",@order.business_id,@ordtl.supplier_id,@ordtl.specification_id).first
      @keyclientorder=@order.keyclientorder
      @stock_logs=@keyclientorder.stock_logs.where(operation: 'b2c_pick_out')
      allchkamt=@stock_logs.where(relationship: @relationship).sum(:check_amount)
      allamt=@stock_logs.where(relationship: @relationship).sum(:amount)
      if allamt > allchkamt
        @stock_logs.where(relationship: @relationship).each do |stock_log|
          if stock_log.amount > stock_log.check_amount
            setchkamt = stock_log.check_amount + 1
            stock_log.check_amount = setchkamt
            stock_log.save
          end
        end
      end
    end
    respond_to do |format|
      format.js 
    end
  end

  def setorallweight
    @order=Order.find(params[:orderid])
    if @order.is_printed
      @isptd=1
      if !params[:orweight].nil?
        allweight=params[:orweight]
        @order.update(total_weight: allweight)
      end
    else
      @isptd=0
    end
    respond_to do |format|
      format.js 
    end
  end

  def findprintindex
    status = Order::STATUS_SHOW_INDEX.keys
    @sku = params[:sku].blank? ? 'false' : params[:sku]
    orders = @orders
    if !@sku.blank? && @sku.eql?('true')
      orders = @orders.includes(:order_details).order('order_details.specification_id')
    end
    @orders_grid = initialize_grid(orders, 
      :include => [:business, :keyclientorder, :order_details], 
      :conditions => ['orders.order_type = ? and orders.status in (?) ',"b2c",status],
      # :order => 'order_details.specification_id',
      # :order_direction => 'asc', 
      :per_page => 15)

    
    @allcnt = {}

    @orders_grid.with_resultset do |orders|

      @@orders_export = orders

    end
    
    # begin
    #   @orders_grid.resultset
    # rescue

    # end

    selectorders = @orders.includes(:keyclientorder).where(status: status,order_type: 'b2c')
    if !params[:grid].blank?
      if !params[:grid][:f].blank?
        params_f = params[:grid][:f]
        if !params_f[:business_id].blank?
          selectorders=selectorders.where(business_id: params_f[:business_id])
        end

        if !params_f[:created_at].blank?
          if !params_f[:created_at][:fr].blank?
            selectorders=selectorders.where("orders.created_at >= ?",params_f[:created_at][:fr])
          end
          if !params_f[:created_at][:to].blank?
            selectorders=selectorders.where("orders.created_at <= ?",params_f[:created_at][:to]+" 23:59:59")
          end
        end

        if !params_f[:transport_type].blank?
          selectorders=selectorders.where(transport_type: params_f[:transport_type])
        end

        if !params_f[:status].blank?
          selectorders=selectorders.where(status: params_f[:status])
        end

        if !params_f[:total_weight].blank?
          if !params_f[:total_weight][:fr].blank?
            selectorders=selectorders.where("orders.total_weight >= ?",params_f[:total_weight][:fr])
          end
          if !params_f[:total_weight][:to].blank?
            selectorders=selectorders.where("orders.total_weight <= ?",params_f[:total_weight][:to])
          end
        end
        
        if !params_f[:tracking_number].blank?
          if !params_f[:tracking_number][:fr].blank?
            selectorders=selectorders.where("orders.tracking_number >= ?",params_f[:tracking_number][:fr])
          end
          if !params_f[:tracking_number][:to].blank?
            selectorders=selectorders.where("orders.tracking_number <= ?",params_f[:tracking_number][:to])
          end
        end

        if !params_f[:business_order_id].blank?
          if !params_f[:business_order_id][:fr].blank?
            selectorders=selectorders.where("orders.business_order_id >= ?",params_f[:business_order_id][:fr])
          end
          if !params_f[:business_order_id][:to].blank?
            selectorders=selectorders.where("orders.business_order_id <= ?",params_f[:business_order_id][:to])
          end
        end

        if !params_f[:country].blank?
          selectorders=selectorders.where("orders.country = ?",params_f[:country])
        end

        if !params_f["keyclientorders.batch_no".to_sym].blank?
          selectorders=selectorders.where("keyclientorders.batch_no = ?", params_f["keyclientorders.batch_no".to_sym])
        end

        if !params_f[:is_printed].blank?
          selectorders=selectorders.where(is_printed: (params_f[:is_printed][0].eql?('t') ? true : false))
        end
      end
    end

    @allcnt = selectorders.includes(:order_details).group(:specification_id,:supplier_id,"orders.business_id").sum(:amount)
    order_count_hash = selectorders.includes(:order_details).group(:specification_id,:supplier_id,"orders.business_id").count(:id)

    order_count_hash.each do |key,value|
      # if order detail missing
      if key[0].blank?
        @allcnt.delete(key)
        next
      end
      order_sum = @allcnt[key]
      stock_sum = Stock.total_stock_in_storage(Specification.find(key[0]), key[1].blank? ? nil : Supplier.find(key[1]), Business.find(key[2]), current_storage,is_broken=false)

      @allcnt[key] = [order_sum,value,stock_sum]
    end
  end

  def stockout
    Keyclientorder.transaction do
      keyclientorder = bind_keyclientorder
      @@orders_export.update_all(keyclientorder_id: keyclientorder.id)
      redirect_to stockout_keyclientorder_url(keyclientorder)
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
      if ! Dir.exist? direct
        Dir.mkdir direct
      end
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
      if ! Dir.exist? direct
        Dir.mkdir direct
      end
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
      # if checkbox_all.eql? '0'
        respond_to do |format|
          format.xls {   
            send_data(exportorders_xls_content_for(find_stock(orders,false,checkbox_all)),  
                :type => "text/excel;charset=utf-8; header=present",  
                :filename => "Orders_#{current_storage.no}_#{Time.now.to_i}.xls")  
          }  
        end
      # else
      #   has_stock_orders = find_has_stock_todo(orders,false)
      #   ordid = []
      #   # if !has_stock_orders.blank?
      #   #   has_stock_orders.each do |o|
      #   #    ordid << o.id
      #   #   end
       
      #   #   # respond_to do |format|
      #   #   #   format.xls {   
      #   #   #     send_data(exportorders_xls_content_for(orders.where.not(id: ordid)),  
      #   #   #       :type => "text/excel;charset=utf-8; header=present",  
      #   #   #       :filename => "Orders_#{current_storage.no}_#{Time.now.to_i}.xls")  
      #   #   #     # send_data(exportorders_xls_content_for(orders.where.not(id: find_has_stock(orders,false).ids)),:type => "text/excel;charset=utf-8; header=present", :filename => "Orders_#{Time.now.strftime("%Y%m%d")}.xls") 
      #   #   #   }  
      #   #   # end
      #   # end
      # end
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
      chilorder = parentorder.children.create(order_type: "b2c",customer_name: parentorder.customer_name,transport_type: parentorder.transport_type,status: 'waiting',business_id: parentorder.business_id,unit_id: parentorder.unit_id,storage_id: parentorder.storage_id,keyclientorder_id: parentorder.keyclientorder_id,is_split: true,customer_name: parentorder.customer_name,customer_unit: parentorder.customer_unit,customer_tel: parentorder.customer_tel,customer_phone: parentorder.customer_phone,customer_address: parentorder.customer_address,customer_postcode: parentorder.customer_postcode,province: parentorder.province,city: parentorder.city,county: parentorder.county, business_order_id: parentorder.business_order_id)
      ods.each do |od|
        curr_specification = Specification.find(od.specification_id)
        scanlabal = "b2cscancuram_" + curr_specification.sixnine_code
        if Integer(params[scanlabal.to_sym]) > 0
          chilorder.order_details.create(name: od.name,specification_id: od.specification_id,amount: params[scanlabal.to_sym],batch_no: od.batch_no,supplier_id: od.supplier_id)
        end
      end

      @porder.update(status: 'spliting')
      #binding.pry
      @order_details = chilorder.order_details
      @order = chilorder
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
    @import_type = ""
    unless request.get?
      if path = upload_orders_import(params[:file]['file'])
        flash_message = "导入成功!"
        Order.transaction do
          begin

            if File.extname(path).eql? '.xlsx'
              instance = Roo::Excelx.new(path)
            elsif File.extname(path).eql? '.xls' 
              instance = Roo::Excel.new(path)
            elsif File.extname(path).eql? '.csv'
              instance = Roo::CSV.new(path)
            else
              raise "导入文件格式错误，只接受xls,xlsx及csv三种文件"
            end

            #Business
            if params[:business_select].blank?
              @import_type = "back"
              type = 2
            else
              @business_id = params[:business_select]
              @import_type = "standard"
              type = 1
            end

            @error_orders = []
            @error_order_details = []

            @ids = extract_orders(instance, type)

            if @import_type.eql?('standard')
              extract_order_details(instance)
            end

            if ! @error_orders.blank? || ! @error_order_details.blank?
              flash_message << "部分订单导入失败！"
            end

            respond_to do |format|
              format.xls {   
                if ! @error_orders.blank? || ! @error_order_details.blank?
                  send_data(exporterrororders_xls_content_for(@error_orders, @error_order_details),  
                  :type => "text/excel;charset=utf-8; header=present",  
                  :filename => "Error_Orders_#{Time.now.strftime("%Y%m%d")}.xls")  
                else
                  redirect_to :action => 'findprintindex'
                end
              }
            end
          rescue => e
            if e.is_a? RuntimeError
              flash[:error] << e.message
            else
              raise e
            end
          end
        end
      end   
    end
  end


  private

  def extract_orders(instance, type)
    #Orders
    instance.default_sheet = instance.sheets.first

    #从第二行开始一直读取，直到空行
    2.upto(instance.last_row) do |line|
      begin
        row = instance.row(line)

        business_order_id = to_string(row[0])
        batch_no = to_string(row[1])
        business_trans_no = to_string(row[2])
        tracking_number = to_string(row[3])
        transport_type = to_string(row[4])
        total_weight = row[5].to_f 
        pingan_ordertime = to_string(row[6])
        customer_unit = to_string(row[7])
        customer_name = to_string(row[8])
        customer_address = to_string(row[9])
        customer_postcode = to_string(row[10])
        country = to_string(row[11])
        province = to_string(row[12])
        city = to_string(row[13]) 
        county = to_string(row[14])
        customer_tel = to_string(row[15])
        customer_phone = to_string(row[16])
        business_no = to_string(row[17])
        business_name = to_string(row[18])
        send_name = to_string(row[21])
        send_province = to_string(row[22])
        send_city = to_string(row[23])
        send_addr = to_string(row[24])
        send_mobile = to_string(row[25])
        local_name = to_string(row[26])
        local_country = to_string(row[27])
        local_province = to_string(row[28])
        local_city = to_string(row[29])
        local_addr = to_string(row[30])
        is_printed = false
        status = Order::STATUS[:waiting]
        virtual = to_string(row[31])
        virtual = "0" if virtual.blank?

        if batch_no.blank?
          raise "缺少外部订单号" if business_order_id.blank?
            
          if ! business_trans_no.blank? && ! business_trans_no.eql?(business_order_id)
              business_order_id = business_trans_no
          end

          #Load Business
          business = Business.accessible_by(current_ability).find @business_id if ! @business_id.blank?

          business ||= Business.accessible_by(current_ability).find_by(no: business_no) if ! business_no.blank?
             
          raise "商户编号缺失或错误" if business.blank?
            
          #Load Order
          order = Order.accessible_by(current_ability).find_by  business_order_id: business_order_id, business_id: business.id
        else
          #Load Order
          order = Order.accessible_by(current_ability).find_by  batch_no: batch_no

          raise "批次号错误" if order.blank?
        end

        if ! order.blank?
          if type == 1
            raise "订单已处理" if ! order.status.eql?(Order::STATUS[:waiting])
          end
        end

        #Tracking info
        raise "物流单号和物流供应商需完整" if transport_single(transport_type,tracking_number)

        if ! transport_type.blank? && ! tracking_number.blank?
          logistic = find_logistic(transport_type)
          transport_type = logistic.blank?? nil:logistic.print_format

          raise "物流供应商错误" if transport_type.blank?
           
          # status = Order::STATUS[:printed]
          is_printed = true
          # if @keyclientorder.blank?
          #   @keyclientorder = bind_keyclientorder
          # end
          # keyclientorder = @keyclientorder
        # else
          # status = Order::STATUS[:waiting]
          # keyclientorder = nil
        end

        if order.blank? 
          order = Order.create!(order_type: 'b2c',business_order_id: business_order_id, tracking_number: tracking_number, transport_type: transport_type, total_weight: total_weight, pingan_ordertime: pingan_ordertime, customer_unit: customer_unit, customer_name: customer_name, customer_address: customer_address, customer_postcode: customer_postcode,
            country: country,
            province: province, 
            city: city, 
            county: county, customer_tel: customer_tel, 
            customer_phone: customer_phone, 
            business: business, 
            unit_id: current_user.unit.id, 
            storage_id: current_storage.id, 
            status: status, 
            # keyclientorder: keyclientorder, 
            user_id: current_user.id,
            send_name: send_name,
            send_province: send_province,
            send_city: send_city,
            send_addr: send_addr,
            send_mobile: send_mobile,
            local_name: local_name,
            local_country: local_country,
            local_province: local_province,
            local_city: local_city,
            local_addr: local_addr,
            logistic: logistic,
            is_printed: is_printed,
            virtual: virtual)

          # ords[0] = order
          # if find_has_stock(ords,false).blank?
          #   is_shortage = "yes"
          # else
          #   is_shortage = "no"
          # end
          # Order.update(order.id, is_shortage: is_shortage)
                    
          @ids << order.id
        else
          order.update!(tracking_number: tracking_number, transport_type: transport_type, total_weight: total_weight, pingan_ordertime: pingan_ordertime, customer_unit: customer_unit, customer_name: customer_name, customer_address: customer_address, customer_postcode: customer_postcode, country: country, province: province, city: city, county: county, customer_tel: customer_tel, customer_phone: customer_phone, 
            # 面单回馈不需要改变订单状态
            # status: status, 
            # keyclientorder: keyclientorder,
            user_id: current_user.id,
            send_name: send_name,
            send_province: send_province,
            send_city: send_city,
            send_addr: send_addr,
            send_mobile: send_mobile,
            local_name: local_name,
            local_country: local_country,
            local_province: local_province,
            local_city: local_city,
            local_addr: local_addr,
            logistic: logistic, 
            is_printed: is_printed,
            virtual: virtual)

          if type == 1
            order.order_details.destroy_all
          end
        
          # ords[0] = order
          # if find_has_stock(ords,false).blank?
          #   is_shortage = "yes"
          # else
          #   is_shortage = "no"
          # end
          # Order.update(order.id,is_shortage: is_shortage)
                  
          @ids << order.id
        end          
      rescue => e
        if e.is_a? RuntimeError
           @error_orders << (row << e.message)
        else
          raise e
        end
      ensure
        line += 1
      end
    end
    return @ids
  end

  def extract_order_details(instance)
    #读取订单明细     
    instance.default_sheet = instance.sheets.second
    order = nil

    2.upto(instance.last_row) do |line|
      begin
        row = instance.row(line)

        order = nil

        # orderarr << row
        business_order_id = to_string(row[0])
        sub_order_id = to_string(row[1])
        sku_extcode_69code = to_string(row[2])
        supplier_no = to_string(row[3])
        amount = to_string(row[4]).to_i
        s_name = to_string(row[5])
        business_no = to_string(row[6])
        business_name = to_string(row[7])
        batch_no = to_string(row[8])
        defective = to_string(row[9])
        defective = "0" if defective.blank?

        if ! supplier_no.blank?
          supplier = Supplier.accessible_by(current_ability).find_by(no: supplier_no)
        end
        
        if batch_no.blank?
          raise "缺少外部订单号" if business_order_id.blank?

          raise "对应订单错误" if exist_in(@error_orders, business_order_id)

          business = Business.accessible_by(current_ability).find_by(id: @business_id) if ! @business_id.blank?
              
          business ||= Business.accessible_by(current_ability).find_by(no: business_no) if ! business_no.blank?

          if business.blank?
            raise "缺少商户编号" if Order.accessible_by(current_ability).where(business_order_id: business_order_id).size != 1

            order = Order.accessible_by(current_ability).find_by business_order_id: business_order_id
          else
            order = Order.accessible_by(current_ability).find_by business_order_id: business_order_id, business_id: business.id
          end
          #Load Order

          

          # order ||= Order.accessible_by(current_ability).find_by business_order_id: sub_order_id, business_id: business.id

          raise "对应订单不存在" if order.blank?
        else
          raise "对应订单错误" if exist_in_batchno(@error_orders, batch_no)

          order = Order.accessible_by(current_ability).find_by batch_no: batch_no

          raise "批次号错误" if order.blank?
        end


        raise "订单已处理" if ! order.status.eql?(Order::STATUS[:waiting]) && ! order.status.eql?(Order::STATUS[:printed])

        raise "缺少sku/第三方编码/69码" if sku_extcode_69code.blank?

        relationship = Relationship.accessible_by(current_ability).find_by barcode: sku_extcode_69code

        relationship ||= Relationship.accessible_by(current_ability).find_by(business_id: order.business_id, external_code: sku_extcode_69code)

        relationship ||= Relationship.accessible_by(current_ability).includes(:specification).find_by(:specifications => {sixnine_code: sku_extcode_69code}, business_id: order.business_id, supplier_id: supplier.try(:id))

        raise "找不到商品信息" if relationship.blank?
                
        raise "商品数量错误" if amount.blank? || amount < 1

        # amount = find_in_instance(orderarr,line,business_order_id,sku_extcode_69code,supplier_no,sub_order_id,temp_amount)
       
        #Load order_detail
        order_detail = order.order_details.find_by(supplier_id: relationship.supplier.try(:id), specification_id: relationship.specification.id)

        # order_detail ||= order.order_details.find_by(business_deliver_no: sub_order_id)

        # business_deliver_no = ""
        # business_trans_no = ""
        # if ! sub_order_id.blank?
        #   if ! order.business_order_id.eql? sub_order_id
        #     business_deliver_no = sub_order_id
        #     # business_trans_no = order.business_order_id
        #   else
        #     business_deliver_no = nil
        #     business_trans_no = to_string(row[0])
        #   end
        # end     

        if order_detail.blank? 
          OrderDetail.create! name: (s_name.blank? ? '' : s_name), batch_no: batch_no, specification: relationship.specification, amount: amount, supplier: relationship.supplier, business_deliver_no: sub_order_id, order: order, defective: defective
        else
          order_detail.update!(amount: order_detail.amount + amount, business_deliver_no: sub_order_id,defective: defective)
        end

        # order.update!(business_trans_no: business_trans_no)

      rescue => e
        if e.is_a? RuntimeError
          @error_order_details << (row << e.message)
          if ! order.blank?
          @error_orders << (order.to_row << '订单已创建，但订单明细错误')
          end
        else
          raise e
        end

        # error_orders = order_add(error_orders,0,business_order_id,instance,nil)
              
        # @error_order_details = detail_add(@error_order_details,7,line,instance,txt)

        # order_detail_error_handle(row,business.id,txt,orderarr,error_orders,@error_order_details,type)
      ensure
        line = line + 1
      end
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def order_params
    params.require(:order).permit(:no,:order_type, :need_invoice ,:customer_name,:customer_unit ,:customer_tel,:customer_phone,:province,:city,:county,:customer_address,:customer_postcode,:customer_email,:total_weight,:total_price ,:total_amount,:transport_type,:transport_price,:pay_type,:status,:buyer_desc,:seller_desc,:business_id,:unit_id,:storage_id,:keyclientorder_id,:logistic_id)
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

    sheet1.row(0).concat %w{订单号(外部) 订单流水号 子订单号 物流单号 物流供应商 重量(g) 下单时间 客户单位 收件客户 收件详细地址 收货邮编 收件国家 收件省 收件市 收件县区 收件人联系电话 收货手机 商户编号 商户名称 状态 商品信息 寄件客户 寄件省 寄件市 寄件地址 寄件人电话 当地收件人名称 当地国家 当地省 当地市 当地地址 是否虚拟}  
    count_row = 1
    objs.each do |obj|
      if obj.is_shortage.eql? 'yes'
        red = Spreadsheet::Format.new :color => :red
        sheet1.row(count_row).default_format = red  
      end
      logistic = Logistic.find_by(id:obj.logistic_id) if !obj.logistic_id.blank?
      transport_type = logistic.blank?? "":logistic.name
      
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
      sheet1[count_row,1]=obj.batch_no
      sheet1[count_row,2]=business_trans_no
      sheet1[count_row,3]=obj.tracking_number.to_s
      sheet1[count_row,4]=transport_type
      sheet1[count_row,5]=obj.total_weight
      sheet1[count_row,6]=obj.pingan_ordertime
      sheet1[count_row,7]=obj.customer_unit
      sheet1[count_row,8]=obj.customer_name
      sheet1[count_row,9]=obj.customer_address
      sheet1[count_row,10]=obj.customer_postcode
      sheet1[count_row,11]=obj.country
      sheet1[count_row,12]=obj.province
      sheet1[count_row,13]=obj.city
      sheet1[count_row,14]=obj.county
      sheet1[count_row,15]=obj.customer_tel
      sheet1[count_row,16]=obj.customer_phone
      sheet1[count_row,17]=obj.business.no
      sheet1[count_row,18]=obj.business.name
      sheet1[count_row,19]=obj.status_name
      sheet1[count_row,20]=all_name[0,all_name.size-1]
      sheet1[count_row,21]=obj.send_name
      sheet1[count_row,22]=obj.send_province
      sheet1[count_row,23]=obj.send_city
      sheet1[count_row,24]=obj.send_addr
      sheet1[count_row,25]=obj.send_mobile
      sheet1[count_row,26]=obj.local_name
      sheet1[count_row,27]=obj.local_country
      sheet1[count_row,28]=obj.local_province
      sheet1[count_row,29]=obj.local_city
      sheet1[count_row,30]=obj.local_addr
      sheet1[count_row,31]=obj.virtual_name

      count_row += 1
    end  

    sheet2 = book.create_worksheet :name => "OrderDetails"
    detail_row = 0
    sheet2.row(detail_row).default_format = blue 
    sheet2.row(detail_row).concat %w{订单号(外部) 子订单号 SKU/第三方编码/69码 供应商编号 数量 商品名称 商户编号 商户名称 订单流水号 是否残次品}
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
        s = Supplier.accessible_by(current_ability).find_by('id = ?',"#{supplier_id}")
        supplier_no = s.blank? ? nil : s.no

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

        sku_extcode_69code = relationship.blank? ? nil : relationship.barcode
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
        sheet2[detail_row,9]=order_detail.defective_name
        
        detail_row += 1
      end
    end

    book.write xls_report  
    xls_report.string  
  end

  def getTrackingNumber(transport_type, tracking_number, line=nil)
    return_no = []
    case transport_type
    when "tcsd","同城速递","tcxb","同城小包"
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

  def bind_keyclientorder()
    # batch_no = time.year.to_s+time.month.to_s.rjust(2,'0')+time.day.to_s.rjust(2,'0')+Keyclientorder.count.to_s.rjust(5,'0')
    Keyclientorder.create(keyclient_name: "订单波次 #{DateTime.parse(Time.now.to_s).strftime('%Y-%m-%d %H:%M:%S').to_s}", unit_id: current_user.unit_id, storage_id: current_storage.id, user: current_user, status: Order::STATUS[:printed])
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
      if to_string(x[0]).eql?(id) && !to_string(x.last).eql?("订单已创建，但订单明细错误")
        return true
      else
        next
      end
    end
    return false
  end

  def exist_in_batchno(arrays,id)
    arrays.each do |x|
      if to_string(x[16]).eql?(id) && !to_string(x.last).eql?("订单已创建，但订单明细错误")
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

  def detail_add(target,index,line,instance,txt=nil)
    instance.default_sheet = instance.sheets.second
    # 2.upto(instance.last_row) do |line|
      index_content = 15
      if index == 0
        index_content = 0
      end
      # if to_string(instance.row(line)[index]).eql? to_string(content[index_content])
        if target.find{|x| x == instance.row(line)}.blank?
          target << (instance.row(line) << txt)
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
        batch_no = to_string(x[16])
        order = nil
        if !batch_no.blank?
          order = Order.accessible_by(current_ability).find_by batch_no: batch_no
        elsif !business_id.blank?
          order = Order.accessible_by(current_ability).find_by business_order_id: business_id
        end
        # skip the exist order and delete the new order
        if !order.blank? && (order.created_at == order.updated_at)
          order.order_details.destroy_all
          order.delete
        end
      end
    when 2
      #  update the order status to waiting and clean transtype info
      target.each do |x|
        business_id = to_string(x[0])
        batch_no = to_string(x[16])
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

    sheet1.row(0).concat %w{订单号(外部) 订单流水号 子订单号 物流单号 物流供应商 重量(g) 下单时间 客户单位 收件客户 收件详细地址 收货邮编 收件国家 收件省 收件市 收件县区 收件人联系电话 收货手机 商户编号 商户名称 状态 商品信息 寄件客户 寄件省 寄件市 寄件地址 寄件人电话 当地收件人名称 当地国家 当地省 当地市 当地地址 是否虚拟}  
    count_row = 1
    obj1.each do |obj|
      sheet1[count_row,0]=obj[0]
      sheet1[count_row,1]=obj[1]
      sheet1[count_row,2]=obj[2]
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
      sheet1[count_row,21]=obj[21]
      sheet1[count_row,22]=obj[22]
      sheet1[count_row,23]=obj[23]
      sheet1[count_row,24]=obj[24]
      sheet1[count_row,25]=obj[25]
      sheet1[count_row,26]=obj[26]
      sheet1[count_row,27]=obj[27]
      sheet1[count_row,28]=obj[28]
      sheet1[count_row,29]=obj[29]
      sheet1[count_row,30]=obj[30]
      sheet1[count_row,31]=obj[31]
      sheet1[count_row,32]=obj[32]
      
      count_row += 1
    end  

    sheet2 = book.create_worksheet :name => "OrderDetails"
    detail_row = 0
    sheet2.row(detail_row).default_format = blue 
    sheet2.row(detail_row).concat %w{订单号(外部) 子订单号 SKU/第三方编码/69码 供应商编号 数量 商品名称 商户编号 商户名称 订单流水号 是否残次品}
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
        sheet2[detail_row,10]=obj[10]
        
        detail_row += 1
      # end
    end

    book.write xls_report  
    xls_report.string  
  end

  # def find_in_instance(instance,line,business_order_id,sku_extcode_69code,supplier_no,business_deliver_no,amount)
  #   instance.default_sheet = instance.sheets.second
  #   amount=amount.to_i
  #   # binding.pry
  #   2.upto(line-1) do |line|
  #     re=(to_string(instance.row(line)[0]).eql?business_order_id and to_string(instance.row(line)[2]).eql?sku_extcode_69code and to_string(instance.row(line)[3]).eql?supplier_no)
  #     if !business_deliver_no.blank?
  #       re=(re and to_string(instance.row(line)[1]).eql?business_deliver_no)
  #     end
  #     if re
  #       amount=amount+to_string(instance.row(line)[4]).to_i
  #     end
  #   end
  #   return amount
  # end

  def find_in_instance(orderarr,line,business_order_id,sku_extcode_69code,supplier_no,business_deliver_no,amount)
    amount=amount.to_i
    0.upto(orderarr.size-2) do |d|
      re=(to_string(orderarr[d][0]).eql?business_order_id and to_string(orderarr[d][2]).eql?sku_extcode_69code and to_string(orderarr[d][3]).eql?supplier_no)
      if !business_deliver_no.blank?
        re=(re and to_string(orderarr[d][1]).eql?business_deliver_no)
      end
      if re
        amount=amount+to_string(orderarr[d][4]).to_i
      end
    end
    return amount
  end


  def find_logistic(transport_type)
    # case transport_type
    #   when "同城速递","tcsd","TCSD","同城小包","tcxb","TCXB"
    #     tran_type = 'tcsd'
    #   when "国内小包","gnxb","GNXB"
    #     tran_type = 'gnxb'  
    #   when "EMS","ems"
    #     tran_type = 'ems'
    #   when "天天快递","ttkd","TTKD"
    #     tran_type = 'ttkd'
    #   when "百世汇通","bsht","BSHT"
    #     tran_type = 'bsht'
    #   when "其他","qt","QT"
    #     tran_type = 'qt'
    #   else
    #     tran_type = nil
    # end
    logistic = Logistic.find_by(name:transport_type)
    logistic ||= Logistic.find_by(print_format:transport_type.downcase)
    return logistic.blank?? nil:logistic
  end

  def transport_single(trantype,tracknumber)
    if (!trantype.blank? and tracknumber.blank?) or (!tracknumber.blank? and trantype.blank?)
      return true
    else 
      return false
    end
  end

  def order_detail_error_handle(row,business_id,txt,orderarr,error_orders,error_order_details,type)
    business_order_id =to_string(row[0])
    batch_no = to_string(row[16])
    if !batch_no.blank?
      order = Order.accessible_by(current_ability).find_by batch_no: batch_no
    elsif !business_order_id.blank? and !business_id.blank?
      order = Order.accessible_by(current_ability).find_by business_order_id: business_order_id,business_id:business_id
    end
    if !order.blank? 
      if type ==1   
        if order.created_at == order.updated_at
          order.order_details.destroy_all
          order.delete
        end
      end
      if type ==2
        order.status = 'waiting'
        order.tracking_number = nil
        order.transport_type=nil
        order.user_id=nil
        order.keyclientorder_id=nil
        order.save
      end
      if error_order_details.find{|x| x == row}.blank?
        error_order_details << (row << txt)
      end
      0.upto(orderarr.size-1) do |o|
        if orderarr[o][0].eql?business_order_id
          error_orders << orderarr[o]
        end
      end    
    end
    if order.blank?
      if error_order_details.find{|x| x == row}.blank?
        error_order_details << (row << txt)
      end
    end
  end

  
end
