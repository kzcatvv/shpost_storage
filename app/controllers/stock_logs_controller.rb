class StockLogsController < ApplicationController
  # before_filter :find_current_storage
  load_and_authorize_resource

  # GET /stock_logs
  # GET /stock_logs.json
  def index
    @stock_logs_grid = initialize_grid(@stock_logs, include: :user)
  end

  # GET /stock_logs/1
  # GET /stock_logs/1.json
  def show
  end

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

  def updateall
    stock_logs = params[:stock_logs]
    if !stock_logs.nil?
      stock_logs.each do |stock_log|
        @stock_log = StockLog.find(stock_log[:id])
        @stock = @stock_log.stock
        if !stock_log[:shelfid].nil?
          @stock.shelf_id = stock_log[:shelfid]
          @stock_log.save()
        end
        
        if !stock_log[:amount].nil?
        # @stock_log.status = stock_log[:status]
          @stock_log.amount = stock_log[:amount]
          @stock.save()
        end
      end
    end
    redirect_to request.referer
  end

  def modify
    @stock_log = StockLog.find(params[:id])
    @stock = @stock_log.stock
    if !params[:shelfid].nil?
      @stock.shelf_id = params[:shelfid]
      @stock.save()
    end

    if !params[:amount].nil?
      @stock_log.amount = params[:amount]
      @stock_log.save()
    end
    redirect_to request.referer
  end

  def split
    @stock_log_update = StockLog.find(params[:id])
    @stock_update = @stock_log.stock
    
    @stock_log_update.amount = @stock_log_update.amount
    @stock_log_update.save()

    @stock_log_new = StockLog.new
    @stock_new = Stock.new()

    @stock_log_new.amount = 0
    @stock_log_new.user_id = @stock_log_update.user_id
    @stock_log_new.operation = @stock_log_update.operation
    @stock_log_new.status = @stock_log_update.status
    @stock_log_new.object_class = @stock_log_update.object_class
    @stock_log_new.object_primary_key = @stock_log_update.object_primary_key
    @stock_log_new.object_symbol = @stock_log_update.object_symbol
    @stock_log_new.operation_type = @stock_log_update.operation_type
    @stock_log_new.desc = @stock_log_update.desc

    @stock_new.shelf_id = @stock_update.shelf_id
    @stock_new.business_id = @stock_update.business_id
    @stock_new.supplier_id = @stock_update.supplier_id
    @stock_new.specification_id = @stock_update.specification_id
    @stock_new.actual_amount = @stock_update.actual_amount
    @stock_new.virtual_amount = @stock_update.virtual_amount
    @stock_new.desc = @stock_update.desc
    @stock_new.stock_logs << @stock_log_new

    @stock_new.save()

    redirect_to request.referer
  end
end
