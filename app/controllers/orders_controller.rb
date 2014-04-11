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
    @order.order_type = "pubiicclient"
    @order.unit_id = current_user.unit_id
#@order.storage_id = current_storage.id 

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

  def findprint
    @orders = Order.where(" order_type = ? and status = ? ","b2c","waiting").joins("LEFT JOIN order_details ON order_details.order_id = orders.id").order("order_details.specification_id").limit(25).distinct
    allcnt = {}
    @orders.each do |o|
      o.order_details.each do |d|
        product = [o.business_id,d.specification_id,d.supplier_id]
        allamount = Stock.find_stock_amount(d.specification,o.business,d.supplier)
        if allcnt.has_key?(product)
          if allcnt[product][0]-allcnt[product][1]-d.amount >= 0
            allcnt[product][1]=allcnt[product][1]+d.amount
          else
            @orders = @orders.where("orders.id not in (?)",o)
          end
        else
          if allamount - d.amount >= 0
            allcnt[product]=[allamount,d.amount]
          else
            @orders = @orders.where("orders.id not in (?)",o)
          end
        end
      end
    end

  end

  def findcheck
    @orders = Order.where(" order_type = ? and status = ? and user_id = ?","b2c","printed",current_user).limit(25)
  end

  def stockout
    if !params[:keyclientorder_id].nil?
       keyorder=Keyclientorder.find(params[:keyclientorder_id])
       @orders = keyorder.orders
    end

    @orders.each do |order|
      order.order_details.each do |orderdtl|
          if orderdtl.amount > 0
            outstocks = Stock.find_out_stock(orderdtl.specification, order.business, orderdtl.supplier)

              outbl = false
              amount = orderdtl.amount
              while orderdtl.amount - orderdtl.stock_logs.sum(:amount) > 0
                amount = orderdtl.amount - orderdtl.stock_logs.sum(:amount) 
                outstocks.each do |outstock|
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
          sklogs = orderdtl.stock_logs
          @stock_logs += StockLog.where(id: sklogs)
      end
    end
    @orders.update_all(status: "unchecked",user_id: nil)
    binding.pry
    @stock_logs_grid = initialize_grid(@stock_logs)
    #binding.pry
  end

  # def check_out_stocks(stocks,amount)
  #   chkout = false
  #   stocks.each do |stock|
  #     if !chkout
  #      if stock.virtual_amount - amount >= 0
  #         chkout = true
  #      else 
  #         amount = amount - stock.virtual_amount
  #         chkout = false
  #      end
  #     end
  #   end
  #   return chkout
  # end

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
