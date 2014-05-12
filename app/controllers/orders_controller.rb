class OrdersController < ApplicationController
  load_and_authorize_resource

  # GET /orderes
  # GET /orderes.json
  def index
    @orders_grid = initialize_grid(@orders,
                   :conditions => {:order_type => "b2c"})
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

    @orders = Order.where(" order_type = ? and status = ? ","b2c","waiting").joins("LEFT JOIN order_details ON order_details.order_id = orders.id").order("order_details.specification_id").distinct
    find_has_stock(@orders)
    
   else
    @keycorder=Keyclientorder.where(keyclient_name: "auto",user: current_user,status: "waiting").order('batch_id').first
    @orders=@keycorder.orders
    #find_has_stock(@orders)
   end

  end

  def find_has_stock(orders)
    allcnt = {}
    findorders = []
    ordercnt = 0
    orders.each do |o|
     hasstockchk = true
     if ordercnt < 25
      o.order_details.each do |d|
        product = [o.business_id,d.specification_id,d.supplier_id]
        allamount = Stock.total_stock_in_storage(d.specification, d.supplier, o.business, current_storage)
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
     end
    end
    
    if ordercnt > 0
      time = Time.new
      batch_id = time.year.to_s+time.month.to_s.rjust(2,'0')+time.day.to_s.rjust(2,'0')+Keyclientorder.count.to_s.rjust(5,'0')
      @keycorder = Keyclientorder.create(keyclient_name: "auto",unit_id: current_user.unit_id,storage_id: session[:current_storage].id,batch_id: batch_id,user: current_user,status: "waiting")
      orders=Order.where(id: findorders)
      orders.update_all(keyclientorder_id: @keycorder)

      allcnt.each do |k,v|
         if v[1] > 0
          Keyclientorderdetail.create(keyclientorder: @keycorder,business_id: k[0],specification_id: k[1],supplier_id: k[2],amount: v[1])
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

   if !params[:keyclientorder_id].nil?
       sklogs=[]
       chkout=0
       has_out=0
       @keycorder=params[:keyclientorder_id]
       keyorder=Keyclientorder.find(params[:keyclientorder_id])
       @orders = keyorder.orders
       

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
        sklogs=StockLog.where(id: keyorder.stock_logs)

   else
    sklogs=[]
    chkout=0
    @keycorder=params[:format]
    @keyclientorder=Keyclientorder.find(params[:format])
    @orders=@keyclientorder.orders
    @orders.each do |order|

     if check_out_stocks(order)
      order.order_details.each do |orderdtl|
          if orderdtl.amount > 0
            outstocks = Stock.find_stocks_in_storage(orderdtl.specification, orderdtl.supplier, order.business, current_storage).to_ary
            outbl = false
            amount = orderdtl.amount

              if orderdtl.amount - orderdtl.stock_logs.sum(:amount) > 0
                amount = orderdtl.amount - orderdtl.stock_logs.sum(:amount) 
                 outstocks.each do |outstock|
                   if outstock.virtual_amount > 0
                    if !outbl
                      if outstock.virtual_amount - amount >= 0
                       setamount = outstock.virtual_amount - amount
                       outbl = true
                       outstock.update_attribute(:virtual_amount , setamount)
                       outstock.save
                       keyorderdtl=@keyclientorder.keyclientorderdetails.where(business_id: order.business_id,specification_id: orderdtl.specification_id,supplier_id: orderdtl.supplier_id).first
                       stklog = StockLog.create(stock: outstock, user: current_user, operation: StockLog::OPERATION[:b2c_stock_out], status: StockLog::STATUS[:waiting], amount: amount, operation_type: StockLog::OPERATION_TYPE[:out],keyclientorderdetail: keyorderdtl)
                       orderdtl.stock_logs << stklog
                      else 
                       amount = amount - outstock.virtual_amount
                       outbl = false
                       keyorderdtl=@keyclientorder.keyclientorderdetails.where(business_id: order.business_id,specification_id: orderdtl.specification_id,supplier_id: orderdtl.supplier_id).first
                       stklog = StockLog.create(stock: outstock, user: current_user, operation: StockLog::OPERATION[:b2c_stock_out], status: StockLog::STATUS[:waiting], amount: outstock.virtual_amount, operation_type: StockLog::OPERATION_TYPE[:out],keyclientorderdetail: keyorderdtl)
                       orderdtl.stock_logs << stklog
                       outstock.update_attribute(:virtual_amount , 0)
                       outstock.save
                      end
                    end
                   end
                 end
              end

          end
          sklogs += orderdtl.stock_logs
      end
        order.update_attribute(:is_shortage,"no")
     else
       chkout += 1
       order.update_attribute(:is_shortage,"yes")
     end
    end

   end
    #@orders.update_all(status: "unchecked",user_id: nil)
    @stock_logs = StockLog.where(id: sklogs)
    #binding.pry
    @stock_logs_grid = initialize_grid(@stock_logs)
    if chkout > 0
     flash.now[:notice] = "注意有"+chkout.to_s+"件订单缺货"
    end
    #binding.pry
  end

  def check_out_stocks(order)
   
    orderchk = true 
    order.order_details.each do |odl|
      hasout=odl.stock_logs.sum(:amount)
      if odl.amount - hasout > 0
       outstocks = Stock.find_stocks_in_storage(odl.specification, odl.supplier, order.business, current_storage).to_ary
       chkout = false
       amount = odl.amount - hasout
       outstocks.each do |stock|
        if !chkout
         if stock.virtual_amount - amount >= 0
            chkout = true
         else 
            amount = amount - stock.virtual_amount
            chkout = false
         end
        end
       end
       orderchk= orderchk && chkout
      end 
    end
    return orderchk
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
      @orders.each do |order|
        order.stock_logs.each do |stlog|
          stlog.order_check
        end
        order.stock_out
      end
      
     if @keyclientorder.keyclient_name == "auto"
        redirect_to :action => 'findprint'
     else
        redirect_to "/keyclientorders"
     end

  end

  def packout
      @order_details=[]
      @curr_order=""
  end

  def findorderout
      @order=Order.where(tracking_number: params[:tracking_number],status: "checked").first
      if @order.nil?
        @order_details=[]
        @curr_order=0

        @order=Order.find(params[:orderid])
      # @order_details=@order.order_details
      # @curr_order=@order.id
        curr_dtls=@order.order_details.includes(:specification).where("specifications.sixnine_code = ?",params[:tracking_number]).distinct.first
        if curr_dtls.nil?
           @curr_dtl=0
        else
           @curr_dtl=curr_dtls.id
        end 
      else
        @curr_order=@order.id
        @order_details=@order.order_details
        @curr_dtl=0
        @dtl_cnt=@order.order_details.count
        @act_cnt=0
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
     @orders_grid = initialize_grid(@orders,
                   :include => [:business],
                   :conditions => {:order_type => "b2c"})
     @allcnt = {}
     @allcnt.clear
     @slorders = initialize_grid(@orders, :include => [:business], :conditions => {:order_type => "b2c",:status => "waiting"}).resultset.limit(nil).to_ary
     @selectorders=Order.where(id: @slorders)
     if !params[:grid].nil?
       if !params[:grid][:f]["businesses.name".to_sym].nil?
        businessid=Business.where("name = ?",params[:grid][:f]["businesses.name".to_sym])
        @selectorders=@selectorders.where(:business_id,businessid)
       end

       if !params[:grid][:f][:created_at].nil?
        @selectorders=@selectorders.where(["created_at >= ? and created_at <= ?",params[:grid][:f][:created_at][:fr],params[:grid][:f][:created_at][:to] ])
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

  private
    # Use callbacks to share common setup or constraints between actions.
    #def set_order
    #  @order = Order.find(params[:id])
    #end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:no,:order_type, :need_invoice ,:customer_name,:customer_unit ,:customer_tel,:customer_phone,:province,:city,:county,:customer_address,:customer_postcode,:customer_email,:total_weight,:total_price ,:total_amount,:transport_type,:transport_price,:pay_type,:status,:buyer_desc,:seller_desc,:business_id,:unit_id,:storage_id,:keyclientorder_id)
    end
end
