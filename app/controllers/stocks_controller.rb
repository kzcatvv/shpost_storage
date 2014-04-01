class StocksController < ApplicationController
  load_and_authorize_resource

  # GET /stocks
  # GET /stocks.json
  def index
    @stocks_grid = initialize_grid(@stocks)
  end

  # GET /stocks/1
  # GET /stocks/1.json
  def show
  end

  # GET /stocks/new
  def new
  end

  # GET /stocks/1/edit
  def edit
  end

  # POST /stocks
  # POST /stocks.json
  def create
    respond_to do |format|
      if @stock.save
        @stock_log = StockLog.create(user: current_user, stock: @stock, operation: 'create_stock', status: 'checked', operation_type: 'in', amount: @stock.actual_amount, checked_at: Time.now, desc: "新增库存#{@stock.specification.try(:commodity).try :name}-#{@stock.specification.try :desc}共计#{@stock.actual_amount}，批次：#{@stock.batch_no}，商户：#{@stock.business.try :name}，供应商：#{@stock.supplier.try :name}，货架：@stock.shelf.try :no")
        format.html { redirect_to @stock, notice: 'Stock was successfully created.' }
        format.json { render action: 'show', status: :created, location: @stock }
      else
        format.html { render action: 'new' }
        format.json { render json: @stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /stocks/1
  # PATCH/PUT /stocks/1.json
  def update
    respond_to do |format|
      if @stock.update(stock_params)
        format.html { redirect_to @stock, notice: 'Stock was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stocks/1
  # DELETE /stocks/1.json
  def destroy
    @stock.destroy
    @stock_log = StockLog.create(user: current_user, stock: @stock, operation: 'destroy_stock', status: 'checked', operation_type: 'out', amount: @stock.actual_amount, checked_at: Time.now, desc: "新增库存#{@stock.specification.try(:commodity).try :name}-#{@stock.specification.try :desc}共计#{@stock.actual_amount}，批次：#{@stock.batch_no}，商户：#{@stock.business.try :name}，供应商：#{@stock.supplier.try :name}，货架：@stock.shelf.try :no")
    respond_to do |format|
      format.html { redirect_to stocks_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    # def set_stock
    #   @stock = Stock.find(params[:id])
    # end

    # Never trust parameters from the scary internet, only allow the white list through.
    def stock_params
      params.require(:stock).permit(:shelf_id, :business_id, :supplier_id, :purchase_detail_id, :specification_id, :actual_amount, :virtual_amount)
    end
end
