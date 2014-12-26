class StockLogsController < ApplicationController
  # before_filter :find_current_storage
  load_and_authorize_resource
  skip_load_and_authorize_resource only: [:purchase_modify, :remove]

  before_filter :load_params, only: [:modify, :purchase_modify, :remove, :addtr]

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

    stock = Stock.get_available_stock_in_shelf(@arrival.purchase_detail.specification, @arrival.purchase_detail.supplier, @arrival.purchase_detail.purchase.business, @arrival.batch_no, @shelf, false)

    if @stock_log.blank?
      @stock_log = StockLog.create(parent: @arrival.purchase_detail.purchase, stock: stock, status: StockLog::STATUS[:waiting], operation: StockLog::OPERATION[:purchase_stock_in], operation_type: StockLog::OPERATION_TYPE[:in], batch_no: @arrival.batch_no, expiration_date: @arrival.expiration_date)
    else
      @stock_log.update(parent: @arrival.purchase_detail.purchase, stock: stock, batch_no: @arrival.batch_no, expiration_date: @arrival.expiration_date)
    end

    @stock_log.update_amount(@amount)

    total_amount = Stock.total_stock_in_shelf(@stock_log.specification, @stock_log.supplier, @stock_log.business, @stock_log.shelf)

    render json: {id: @stock_log.id, total_amount: total_amount, amount: @stock_log.amount}
  end

  def remove
    if !@stock_log.blank?
      @stock_log.delete
    end
    render text: 'remove'
  end

  def move_stock_modify
    
    if !params[:amount].blank? && !params[:shelf_id].blank? && !params[:stock_id].blank?
      # binding.pry
      @orgstock = Stock.find(params[:stock_id])
      @shelf = Shelf.find(params[:shelf_id])
      stock = Stock.get_available_stock_in_shelf(@orgstock.specification, @orgstock.supplier, @orgstock.business, @orgstock.batch_no, @shelf, false)

      if params[:stocklogid].blank?
        
        @stock_log = StockLog.create(stock: @orgstock,status: StockLog::STATUS[:waiting], operation: StockLog::OPERATION[:move_stock_out], operation_type: StockLog::OPERATION_TYPE[:out], batch_no: @orgstock.batch_no, expiration_date: @orgstock.expiration_date)      
        @pick_stock_log = StockLog.create(stock: stock,status: StockLog::STATUS[:waiting], operation: StockLog::OPERATION[:move_stock_in], operation_type: StockLog::OPERATION_TYPE[:in], batch_no: @orgstock.batch_no, expiration_date: @orgstock.expiration_date)
        @stock_log.pick_in = @pick_stock_log
        @stock_log.save
      else

        @stock_log = StockLog.find(params[:stocklogid])
        @stock_log.update(stock: @orgstock, batch_no: @orgstock.batch_no, expiration_date: @orgstock.expiration_date)
        @stock_log.pick_in.update(stock: stock, batch_no: stock.batch_no, expiration_date: stock.expiration_date)
      
      end

      @stock_log.update_amount(params[:amount])

      total_amount = @stock_log.stock.actual_amount

      render json: {stock_log_id: @stock_log.id, total_amount: total_amount, amount: @stock_log.amount }
    
    else
      render json: {}
    end
   
  end


  def load_params
    @stock_log = StockLog.find(params[:id]) if !params[:id].blank?
    @shelf = Shelf.find(params[:shelf_id]) if !params[:shelf_id].blank?
    (params[:amount].blank?) ? @amount = 0 : @amount = params[:amount].to_i
    @arrival = PurchaseArrival.find(params[:arrival_id]) if !params[:arrival_id].blank?
  end
end
