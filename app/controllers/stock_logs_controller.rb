class StockLogsController < ApplicationController
  # before_filter :find_current_storage
  load_and_authorize_resource
  skip_load_and_authorize_resource only: [:purchase_modify, :manual_stock_modify, :keyclientorder_stock_modify, :remove]

  before_filter :load_params, only: [:modify, :purchase_modify, :manual_stock_modify, :keyclientorder_stock_modify, :remove, :addtr, :order_return_modify]

  # GET /stock_logs
  # GET /stock_logs.json
  def index
    @stock_logs_grid = initialize_grid(@stock_logs, 
      order: "stock_logs.id",
      order_direction: 'desc', 
      include: [:user, :stock, :shelf, :specification])
  end

  # GET /stock_logs/1
  # GET /stock_logs/1.json
  def show
  end

  # # DELETE /stock_logs/1
  # # DELETE /stock_logs/1.json
  # def destroy
  #   @stock = Stock.update(@stock_log.stock, virtual_amount: @stock_log.stock.virtual_amount - @stock_log.amount)
  #   @stock_log.destroy
  #   respond_to do |format|
  #     format.html { redirect_to request.referer }
  #     format.json { head :no_content }
  #   end
  # end

  # def find_current_storage
  #   @areas = Area.where("storage_id = ?", session[:current_storage].id)
  #   @shelves = Shelf.where("area_id in (?)", @areas.ids)
  # end
  def check
    respond_to do |format|
      @stock_log.check!
      format.html { redirect_to stock_logs_url }
      format.json { render :json => "success".to_json}#, :callback => "process_user" }
    end
  end

  def stockindex
    @stock_logs_grid = initialize_grid(@stock_logs, include: [:user,:stock])
  end

  def purchase_modify
    if @shelf.blank? || @arrival.blank?
      return render json: {}
    end

    stock = Stock.get_available_stock_in_shelf(@arrival.purchase_detail.specification, @arrival.purchase_detail.supplier, @arrival.purchase_detail.purchase.business, @arrival.batch_no, @shelf)

    if @stock_log.try :waiting?
      @stock_log.update(parent: @arrival.purchase_detail.purchase, stock: stock, operation: StockLog::OPERATION[:purchase_stock_in], operation_type: StockLog::OPERATION_TYPE[:in], expiration_date: @arrival.expiration_date)
    else
      @stock_log = StockLog.create(parent: @arrival.purchase_detail.purchase, stock: stock, status: StockLog::STATUS[:waiting], operation: StockLog::OPERATION[:purchase_stock_in], operation_type: StockLog::OPERATION_TYPE[:in], expiration_date: @arrival.expiration_date)      
    end

    @stock_log.update_amount(@amount)

    total_amount = Stock.total_stock_in_shelf(@stock_log.specification, @stock_log.supplier, @stock_log.business, @stock_log.shelf)

    render json: {id: @stock_log.id, total_amount: total_amount, amount: @stock_log.amount}
  end

  def manual_stock_modify
    if @manual_stock_detail.blank?
      return render json: {}
    end

    stocks = Stock.find_stocks_in_storage(@manual_stock_detail.specification, @manual_stock_detail.supplier, @manual_stock_detail.manual_stock.business, current_storage, false)

    stocks_json = stocks.map {|x| {name: "#{x.shelf.shelf_code}(批次:#{x.batch_no},库存:#{x.actual_amount})", id: x.id}}.to_json

    if @stock.blank?
      return render json: {stocks: stocks_json}
    else
      if @stock_log.try :waiting?
        @stock_log.update(parent: @manual_stock_detail.manual_stock, stock: @stock, operation: StockLog::OPERATION[:b2b_stock_out], operation_type: StockLog::OPERATION_TYPE[:out])
      else
        @stock_log = StockLog.create(parent: @manual_stock_detail.manual_stock, stock: @stock, status: StockLog::STATUS[:waiting], operation: StockLog::OPERATION[:b2b_stock_out], operation_type: StockLog::OPERATION_TYPE[:out])
      end

      @stock_log.update_amount(@amount)

      return render json: {id: @stock_log.id, total_amount: @stock.on_shelf_amount, amount: @stock_log.amount, stocks: stocks_json }
    end
  end

  def keyclientorder_stock_modify
    if @keyclientorder.blank? || @specification.blank? || @business.blank?
      return render json: {}
    end
    
    stocks = Stock.find_stocks_in_storage(@specification,@supplier, @business,current_storage, false)

    stocks_json = stocks.map {|x| {name: "#{x.shelf.shelf_code}(批次:#{x.batch_no},库存:#{x.actual_amount})", id: x.id}}.to_json

    if @stock.blank?
      return render json: {stocks: stocks_json}
    else
      if @stock_log.try :waiting?
        @stock_log.update(parent: @keyclientorder, stock: @stock, operation: StockLog::OPERATION[:b2c_stock_out], operation_type: StockLog::OPERATION_TYPE[:out])
      else
        if @keyclientorder.storage.need_pick
          stocks_in_shelf_type = Stock.find_stocks_in_shelf_type(@specification, @supplier, @business, "pick", false)
            if stocks_in_shelf_type.count > 0
              in_stock = stocks_in_shelf_type.first
              in_shelf_code = in_stock.shelf.shelf_code
            else
              shelves = Shelf.get_empty_pick_shelf(current_storage)
                if shelves.count > 0
                  shelf = shelves.first
                  in_stock = Stock.create(specification: @specification, business: @business, supplier: @supplier, shelf: shelf, actual_amount: 0)
                  in_shelf_code = in_stock.shelf.shelf_code
                else
                  pick_shelves = Shelf.get_pick_shelf(current_storage).to_ary
                  shelf = Shelf.where(id: pick_shelves[0]).first
                  in_stock = Stock.create(specification: @specification, business: @business, supplier: @supplier, shelf: shelf, actual_amount: 0)
                  in_shelf_code = in_stock.shelf.shelf_code
                end

            end
          @stock_log = StockLog.create(parent: @keyclientorder, stock: @stock, status: StockLog::STATUS[:waiting], operation: StockLog::OPERATION[:b2c_stock_out], operation_type: StockLog::OPERATION_TYPE[:out])
          @pick_in_stklog = StockLog.create(parent: @keyclientorder, stock: in_stock, status: StockLog::STATUS[:waiting], operation: StockLog::OPERATION[:b2c_stock_out], operation_type: StockLog::OPERATION_TYPE[:in])
          @stock_log.pick_in = @pick_in_stklog
          @stock_log.save
          @pick_in_stklog.update_amount(@amount)
        else
          @stock_log = StockLog.create(parent: @keyclientorder, stock: @stock, status: StockLog::STATUS[:waiting], operation: StockLog::OPERATION[:b2c_stock_out], operation_type: StockLog::OPERATION_TYPE[:out])
        end
        
      end

      @stock_log.update_amount(@amount)

      return render json: {id: @stock_log.id, total_amount: @stock.on_shelf_amount, amount: @stock_log.amount, stocks: stocks_json, pick_shelf: in_shelf_code }
    end
  end

  def remove
    # binding.pry
      if !@stock_log.blank?
        @stock_log.delete
      end
      if !@stock_log.pick_in.blank?
        @stock_log.pick_in.delete
      end
    render text: 'remove'
  end

  def move_stock_modify
    
    if !params[:amount].blank? && !params[:shelf_id].blank? && !params[:stock_id].blank?
      # binding.pry
      @orgstock = Stock.find(params[:stock_id])
      @shelf = Shelf.find(params[:shelf_id])
      stock = Stock.get_available_stock_in_shelf(@orgstock.specification, @orgstock.supplier, @orgstock.business, @orgstock.batch_no, @shelf)

      if params[:stocklogid].blank?
        @move_stock = MoveStock.find(params[:move_stock_id])
        @stock_log = @move_stock.stock_logs.create(user: current_user ,stock: @orgstock,status: StockLog::STATUS[:waiting], operation: StockLog::OPERATION[:move_stock_out], operation_type: StockLog::OPERATION_TYPE[:out], batch_no: @orgstock.batch_no, expiration_date: @orgstock.expiration_date)      
        @pick_stock_log = @move_stock.stock_logs.create(user: current_user ,stock: stock,status: StockLog::STATUS[:waiting], operation: StockLog::OPERATION[:move_stock_in], operation_type: StockLog::OPERATION_TYPE[:in], batch_no: @orgstock.batch_no, expiration_date: @orgstock.expiration_date)
        @stock_log.pick_in = @pick_stock_log
        @stock_log.save
      else

        @stock_log = StockLog.find(params[:stocklogid])
        @stock_log.update(user: current_user ,stock: @orgstock, batch_no: @orgstock.batch_no, expiration_date: @orgstock.expiration_date)
        @stock_log.pick_in.update(user: current_user ,stock: stock, batch_no: stock.batch_no, expiration_date: stock.expiration_date)
      
      end

      @stock_log.update_amount(Integer(params[:amount]))

      total_amount = @stock_log.stock.blank? ? 0 : @stock_log.stock.actual_amount

      render json: {stock_log_id: @stock_log.id, total_amount: total_amount, amount: @stock_log.amount }
    
    else
      render json: {}
    end
   
  end

  def inventory_modify
    if !params[:amount].blank? && !params[:shelf_id].blank? && !params[:rel_id].blank?
      # binding.pry
      @orgstock = Stock.where("shelf_id = ? and relationship_id = ?",params[:shelf_id],params[:rel_id]).first
      @shelf = Shelf.find(params[:shelf_id])
      if @orgstock.blank?
        @relationship = Relationship.find(params[:rel_id])
        @orgstock = Stock.create(specification: @relationship.specification, business: @relationship.business, supplier: @relationship.supplier, shelf: @shelf, actual_amount: 0, desc: "inv_ca")
      end

      if params[:slid].blank?
        @inventory = Inventory.find(params[:inv_id])
        @stock_log = @inventory.stock_logs.create(user: current_user ,stock: @orgstock,status: StockLog::STATUS[:waiting], operation: StockLog::OPERATION[:inventory], operation_type: StockLog::OPERATION_TYPE[:reset], batch_no: @orgstock.batch_no, expiration_date: @orgstock.expiration_date)      

      else

        @stock_log = StockLog.find(params[:slid])
        @stock_log.update(user: current_user ,stock: @orgstock, batch_no: @orgstock.batch_no, expiration_date: @orgstock.expiration_date)
      
      end

      @stock_log.update_amount(Integer(params[:amount]))

      total_amount = @stock_log.stock.blank? ? 0 : @stock_log.stock.actual_amount

      render json: {stock_log_id: @stock_log.id, total_amount: total_amount, amount: @stock_log.amount }
    
    else
      render json: {}
    end

  end

  def mod_stocklog_pickin_shelf
    if !params[:id].blank?
      @stock_log = StockLog.find(params[:id])
      @shelf = Shelf.find(params[:shelfid])
      @stock_log.pick_in.stock.update(shelf: @shelf)
      @stock_log.pick_in.update(shelf: @shelf)
    end
    render json: {}
  end

  def move_stock_remove
    if !params[:stock_log_id].blank?
      @stock_log=StockLog.find(params[:stock_log_id])
      @stock_log.pick_in.delete
      @stock_log.delete
    end
    render text: 'remove'
  end

  def order_return_modify
    if @shelf.blank? || @return.blank?
      return render json: {}
    end

    is_bad = @return.is_bad

    stock = Stock.get_available_stock_in_shelf(@return.order_detail.specification, @return.order_detail.supplier, @return.order_detail.order.business, @return.order_return.batch_no, @shelf)

    if @stock_log.try :waiting?
      if is_bad.eql?"no"
        @stock_log.update(parent: @return.order_return, stock: stock, operation: StockLog::OPERATION[:order_return], operation_type: StockLog::OPERATION_TYPE[:in], expiration_date: stock.expiration_date)
      else
        @stock_log.update(parent: @return.order_return, stock: stock, operation: StockLog::OPERATION[:order_bad_return], operation_type: StockLog::OPERATION_TYPE[:in], expiration_date: stock.expiration_date)
      end
    else
      if is_bad.eql?"no"
        @stock_log = StockLog.create(parent: @return.order_return, stock: stock, status: StockLog::STATUS[:waiting], operation: StockLog::OPERATION[:order_return], operation_type: StockLog::OPERATION_TYPE[:in], expiration_date: @arrival.expiration_date)   
      else
        @stock_log = StockLog.create(parent: @return.order_return, stock: stock, status: StockLog::STATUS[:waiting], operation: StockLog::OPERATION[:order_bad_return], operation_type: StockLog::OPERATION_TYPE[:in], expiration_date: @arrival.expiration_date) 
      end 
    end

    @stock_log.update_amount(@amount)

    total_amount = Stock.total_stock_in_shelf(@stock_log.specification, @stock_log.supplier, @stock_log.business, @stock_log.shelf)
    # binding.pry
    render json: {id: @stock_log.id, total_amount: total_amount, amount: @stock_log.amount}
  end


  def load_params
    @stock_log = StockLog.find(params[:id]) if !params[:id].blank?
    @shelf = Shelf.find(params[:shelf_id]) if !params[:shelf_id].blank?
    (params[:amount].blank?) ? @amount = 0 : @amount = params[:amount].to_i
    @arrival = PurchaseArrival.find(params[:arrival_id]) if !params[:arrival_id].blank?

    @manual_stock_detail = ManualStockDetail.find(params[:manual_stock_id]) if !params[:manual_stock_id].blank?
    @stock = Stock.find(params[:stock_id]) if !params[:stock_id].blank?
    @keyclientorder = Keyclientorder.find(params[:keyclientorder]) if !params[:keyclientorder].blank?

    if !params[:keyclientorder_params].blank?
      ary = params[:keyclientorder_params].split '_'
      @specification = Specification.find ary[0]
      @business = Business.find ary[1]
      @supplier = Supplier.find ary[2] if !ary[2].blank?
    end

    @return = OrderReturnDetail.find(params[:order_return_detail_id]) if !params[:order_return_detail_id].blank?
  end
end
