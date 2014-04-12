class StockLogsController < ApplicationController
  # before_filter :find_current_storage
  load_and_authorize_resource

  # GET /stock_logs
  # GET /stock_logs.json
  def index
    @stock_logs_grid = initialize_grid(@stock_logs, 
      order: "stock_logs.status",
      order_direction: 'desc', 
      include: [:user, :stock, :shelf])
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
    stock_log = nil
    StockLog.transaction do
      @stock_log = StockLog.find(params[:id])
      @stock = @stock_log.stock
      if !params[:shelfid].nil?
        if params[:shelfid] != @stock.shelf.id.to_s
          stock = Stock.get_stock(@stock.specification, @stock.business, @stock.supplier, @stock.batch_no, Shelf.find(params[:shelfid]), @stock_log.amount)
          if @stock_log.operation_type == StockLog::OPERATION_TYPE[:out]
            @stock.virtual_amount = @stock.virtual_amount + @stock_log.amount
          elsif @stock_log.operation_type == StockLog::OPERATION_TYPE[:in]
            @stock.virtual_amount = @stock.virtual_amount - @stock_log.amount
          end
          @stock.save()
          if !stock
            if @stock_log.operation_type == StockLog::OPERATION_TYPE[:out]
              stock = Stock.create(specification: @stock.specification, business: @stock.business, supplier: @stock.supplier, shelf_id: params[:shelfid], batch_no: @stock.batch_no, actual_amount: 0, virtual_amount: 0 - @stock_log.amount)
            elsif @stock_log.operation_type == StockLog::OPERATION_TYPE[:in]
              stock = Stock.create(specification: @stock.specification, business: @stock.business, supplier: @stock.supplier, shelf_id: params[:shelfid], batch_no: @stock.batch_no, actual_amount: 0, virtual_amount: @stock_log.amount)
            end
             # @stock_log.stock = stock
             # @stock_log.save();
            stock_log = StockLog.update(@stock_log.id, stock: stock)
          else
            if @stock_log.operation_type == StockLog::OPERATION_TYPE[:out]
              stock = Stock.update(stock.id, virtual_amount: stock.virtual_amount - @stock_log.amount)
            elsif @stock_log.operation_type == StockLog::OPERATION_TYPE[:in]
              stock = Stock.update(stock.id, virtual_amount: stock.virtual_amount + @stock_log.amount)
            end
            stock_log = StockLog.update(@stock_log.id, stock: stock)
          end
        end
      end

      if !params[:amount].nil?
        if @stock_log.operation_type == StockLog::OPERATION_TYPE[:out]
          @stock.virtual_amount = @stock.virtual_amount.to_i + @stock_log.amount.to_i - params[:amount].to_i
        elsif @stock_log.operation_type == StockLog::OPERATION_TYPE[:in]
          @stock.virtual_amount = @stock.virtual_amount.to_i - @stock_log.amount.to_i + params[:amount].to_i
        end
        @stock.save()

        @stock_log.amount = params[:amount]
        stock_log = @stock_log.save()
      end

      if !params[:pdid].nil?
        if params[:pdid] != @stock_log.purchase_detail.id.to_s
          pd = PurchaseDetail.find(params[:pdid])
          stock = Stock.get_stock(pd.specification, pd.purchase.business, pd.supplier, pd.batch_no, @stock.shelf, @stock_log.amount)
          @stock.virtual_amount = @stock.virtual_amount - @stock_log.amount
          @stock.save()
          if !stock
            stock = Stock.create(specification: pd.specification, business: pd.purchase.business, supplier: pd.supplier, shelf_id: @stock.shelf.id, batch_no: pd.batch_no, actual_amount: 0, virtual_amount: @stock_log.amount)
            stock_log = StockLog.update(@stock_log.id, stock: stock, purchase_detail_id: params[:pdid])
          else
            stock = Stock.update(stock.id, virtual_amount: stock.virtual_amount + @stock_log.amount)
            stock_log = StockLog.update(@stock_log.id, stock: stock, purchase_detail_id: params[:pdid])
          end
        end
      end
    end
    # redirect_to request.referer
    render json: {id: stock_log.id, actual_amount: stock_log.stock.actual_amount, operation_type: stock_log.operation_type}
  end

  def removetr
    StockLog.transaction do
      @stock_log = StockLog.find(params[:id])
      @stock = @stock_log.stock


      @stock.virtual_amount = @stock.virtual_amount - @stock_log.amount
      @stock.save()

      @stock_log.destroy
    end
    render text: 'removetr'
  end

  def addtr
    StockLog.transaction do

      @stock_log = StockLog.find(params[:id])

      @stock_log_new = StockLog.new
      @stock_log_new.amount = 0
      @stock_log_new.user_id = @stock_log.user_id
      @stock_log_new.operation = @stock_log.operation
      @stock_log_new.purchase_detail = @stock_log.purchase_detail
      @stock_log_new.status = StockLog::STATUS[:waiting]
      @stock_log_new.operation_type = @stock_log.operation_type
      @stock_log_new.desc = @stock_log.desc
      @stock_log_new.stock = @stock_log.stock

      @stock_log_new.save();

      render json: {id: @stock_log_new.id}
    end
  end

  # def split
  #   @stock_log_update = StockLog.find(params[:id])
  #   @stock_update = @stock_log.stock
    
  #   @stock_log_update.amount = @stock_log_update.amount
  #   @stock_log_update.save()

  #   @stock_log_new = StockLog.new
  #   @stock_new = Stock.new()

    
  #   @stock_log_new.amount = 0
  #   @stock_log_new.user_id = @stock_log_update.user_id
  #   @stock_log_new.operation = @stock_log_update.operation
  #   @stock_log_new.status = @stock_log_update.status
  #   @stock_log_new.operation_type = @stock_log_update.operation_type
  #   @stock_log_new.desc = @stock_log_update.desc

  #   puts 111111111111111111
  #   stock = Stock.create(specification: @stock_update.specification, business: @stock_update.business, supplier: @stock_update.supplier, shelf: @stock_update.shelf, batch_no: @stock_update.batch_no, actual_amount: @stock_update.actual_amount, virtual_amount: @stock_update.virtual_amount)
  #   puts 222222222222222222222
  #   # @stock_new.shelf_id = @stock_update.shelf_id
  #   # @stock_new.business_id = @stock_update.business_id
  #   # @stock_new.supplier_id = @stock_update.supplier_id
  #   # @stock_new.specification_id = @stock_update.specification_id
  #   # @stock_new.actual_amount = @stock_update.actual_amount
  #   # @stock_new.virtual_amount = @stock_update.virtual_amount
  #   @stock_new.desc = @stock_update.desc
  #   @stock_new.stock_logs << @stock_log_new

  #   @stock_new.save()

  #   redirect_to request.referer
  # end
end
