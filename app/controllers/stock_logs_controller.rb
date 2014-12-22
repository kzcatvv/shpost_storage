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
      @stock_log = StockLog.create(parent: @arrival.purchase_detail.purchase, stock: stock, amount: @amount, status: StockLog::STATUS[:waiting], operation: StockLog::OPERATION[:purchase_stock_in], operation_type: StockLog::OPERATION_TYPE[:in], batch_no: @arrival.batch_no, expiration_date: @arrival.expiration_date)
    else
      @stock_log.update(parent: @arrival.purchase_detail.purchase, stock: stock, amount: @amount, batch_no: @arrival.batch_no, expiration_date: @arrival.expiration_date)
    end

    render json: {id: @stock_log.id, amount: @stock_log.amount}
  end

  def remove
    if !@stock_log.blank?
      @stock_log.delete
    end
    render text: 'remove'
  end


  def load_params
    @stock_log = StockLog.find(params[:id]) if !params[:id].blank?
    @shelf = Shelf.find(params[:shelf_id]) if !params[:shelf_id].blank?
    (params[:amount].blank?) ? @amount = 0 : @amount = params[:amount]
    @arrival = PurchaseArrival.find(params[:arrival_id]) if !params[:arrival_id].blank?
  end
end
