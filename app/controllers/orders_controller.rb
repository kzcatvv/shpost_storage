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

    time=Time.new
    @order = Order.new(order_params)
    @order.no=time.year.to_s+time.month.to_s.rjust(2,'0')+time.day.to_s.rjust(2,'0')+Order.count.to_s.rjust(5,'0')

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
   if Order.where("status = ? and user_id = ? and order_type = 'b2c' and keyclientorder_id is not null","waiting",current_user).nil?

    @orders = Order.where(" order_type = ? and status = ? ","b2c","waiting").joins("LEFT JOIN order_details ON order_details.order_id = orders.id").order("order_details.specification_id").distinct
    find_has_stock(@orders)
    time = Time.new
    batch_id = time.year.to_s+time.month.to_s.rjust(2,'0')+time.day.to_s.rjust(2,'0')+Keyclientorder.count.to_s.rjust(5,'0')
    keycorder = Keyclientorder.create(unit_id: current_user.unit_id,storage_id: session[:current_storage].id,batch_id: batch_id,user_id: current_user)
    @orders.update_all(keyclientorder_id: keycorder)
   else
    @orders=Order.where("status = ? and user_id = ? and order_type = 'b2c' and keyclientorder_id is not null","waiting",current_user)
    find_has_stock(@orders)
   end

  end

  def find_has_stock(orders)
    allcnt = {}
    orders.each do |o|
      o.order_details.each do |d|
        product = [o.business_id,d.specification_id,d.supplier_id]
        allamount = Stock.find_stock_amount(d.specification,o.business,d.supplier)
        if allcnt.has_key?(product)
          if allcnt[product][0]-allcnt[product][1]-d.amount >= 0
            allcnt[product][1]=allcnt[product][1]+d.amount
          else
            orders = orders.where("orders.id not in (?)",o)
          end
        else
          if allamount - d.amount >= 0
            allcnt[product]=[allamount,d.amount]
          else
            orders = orders.where("orders.id not in (?)",o)
          end
        end
      end
    end
    orders=orders.limit(25)
  end

  def findcheck
    @orders = Order.where(" order_type = ? and status = ? and user_id = ? and keyclientorder_id is not null","b2c","printed",current_user).limit(25)
  end

  def stockout

   if !params[:keyclientorder_id].nil?
       sklogs=[]
       keyorder=Keyclientorder.find(params[:keyclientorder_id])
       @orders = keyorder.orders
       keyordercnt = keyorder.orders.count

        keyorder.keyclientorderdetails.each do |keydtl|
         if keydtl.amount > 0
            outstocks = Stock.find_out_stock(keydtl.specification, keyorder.business, keydtl.supplier)

              outbl = false
              amount = keydtl.amount * keyordercnt
                outstocks.each do |outstock|
                 if outstock.virtual_amount > 0
                  if !outbl
                    if outstock.virtual_amount - amount >= 0
                     setamount = outstock.virtual_amount - amount
                     outbl = true
                     outstock.update_attribute(:virtual_amount , setamount)
                     outstock.save
                     stklog = StockLog.create(stock: outstock, user: current_user, operation: StockLog::OPERATION[:b2b_stock_out], status: StockLog::STATUS[:waiting], amount: amount, operation_type: StockLog::OPERATION_TYPE[:out])
                     sklogs += StockLog.where(id: stklog)
                     ods=OrderDetail.where(order_id: @orders).where(specification_id: keydtl.specification_id,supplier_id: keydtl.supplier_id).offset(keyordercnt-amount/keydtl.amount).limit(amount/keydtl.amount)
                     stklog.order_details << ods
                    else 
                     amount = amount - outstock.virtual_amount
                     outbl = false
                     outstock.update_attribute(:virtual_amount , 0)
                     outstock.save
                     stklog = StockLog.create(stock: outstock, user: current_user, operation: StockLog::OPERATION[:b2b_stock_out], status: StockLog::STATUS[:waiting], amount: outstock.virtual_amount, operation_type: StockLog::OPERATION_TYPE[:out])
                     sklogs += StockLog.where(id: stklog)
                     if amount == keydtl.amount * keyordercnt
                      ods = OrderDetail.where(order_id: @orders).where(specification_id: keydtl.specification_id,supplier_id: keydtl.supplier_id).offset(0).limit(outstock.virtual_amount)
                     else
                      ods = OrderDetail.where(order_id: @orders).where(specification_id: keydtl.specification_id,supplier_id: keydtl.supplier_id).offset(keyordercnt-amount/keydtl.amount).limit(outstock.virtual_amount/keydtl.amount)
                     end

                     stklog.order_details << ods

                    end
                  end
                 end
                end

          end

        end

   else
    sklogs=[]
    @orders.each do |order|
      order.order_details.each do |orderdtl|
          if orderdtl.amount > 0
            outstocks = Stock.find_out_stock(orderdtl.specification, order.business, orderdtl.supplier)

              outbl = false
              amount = orderdtl.amount
              while orderdtl.amount - orderdtl.stock_logs.sum(:amount) > 0
                amount = orderdtl.amount - orderdtl.stock_logs.sum(:amount) 
                outstocks.each do |outstock|
                 if outstock.virtual_amount > 0
                  if !outbl
                    if outstock.virtual_amount - amount >= 0
                     setamount = outstock.virtual_amount - amount
                     outbl = true
                     outstock.update_attribute(:virtual_amount , setamount)
                     outstock.save
                     stklog = StockLog.create(stock: outstock, user: current_user, operation: StockLog::OPERATION[:b2c_stock_out], status: StockLog::STATUS[:waiting], amount: amount, operation_type: StockLog::OPERATION_TYPE[:out])
                     orderdtl.stock_logs << stklog
                    else 
                     amount = amount - outstock.virtual_amount
                     outbl = false
                     outstock.update_attribute(:virtual_amount , 0)
                     outstock.save
                     stklog = StockLog.create(stock: outstock, user: current_user, operation: StockLog::OPERATION[:b2c_stock_out], status: StockLog::STATUS[:waiting], amount: outstock.virtual_amount, operation_type: StockLog::OPERATION_TYPE[:out])
                     orderdtl.stock_logs << stklog
                    end
                  end
                 end
                end
              end

          end
          sklogs += orderdtl.stock_logs
      end
    end
   end
    #@orders.update_all(status: "unchecked",user_id: nil)
    @stock_logs = StockLog.where(id: sklogs)
    #binding.pry
    @stock_logs_grid = initialize_grid(@stock_logs)
  end

  def check_out_stocks(stocks,amount)
    chkout = false
    stocks.each do |stock|
      if !chkout
       if stock.virtual_amount - amount >= 0
          chkout = true
       else 
          amount = amount - stock.virtual_amount
          chkout = false
       end
      end
    end
    return chkout
  end

  def ordercheck
    @stock_logs.each do |stlog|
       stlog.ordercheck
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    #def set_order
    #  @order = Order.find(params[:id])
    #end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:no,:order_type, :need_invoice ,:customer_name,:customer_unit ,:customer_tel,:customer_phone,:province,:city,:customer_address,:customer_postcode,:customer_email,:total_weight,:total_price ,:total_amount,:transport_type,:transport_price,:pay_type,:status,:buyer_desc,:seller_desc,:business_id,:unit_id,:storage_id,:keyclientorder_id)
    end
end
