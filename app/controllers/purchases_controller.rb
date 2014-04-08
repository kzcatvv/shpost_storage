class PurchasesController < ApplicationController
  load_and_authorize_resource

  # GET /purchasees
  # GET /purchasees.json
  def index
    @purchases_grid = initialize_grid(@purchases)
  end

  # GET /purchasees/1
  # GET /purchasees/1.json
  def show
  end

  # GET /purchasees/new
  def new
   # @purchase = Purchase.new
    @purchase.unit = current_user.unit
    @purchase.status = Purchase::STATUS[:waiting]
  end

  # GET /purchasees/1/edit
  def edit
  end

  # POST /purchasees
  # POST /purchasees.json
  def create
   # @purchase = Purchase.new(purchase_params)

    respond_to do |format|
      if @purchase.save
        format.html { redirect_to @purchase, notice: 'Purchase was successfully created.' }
        format.json { render action: 'show', status: :created, location: @purchase }
      else
        format.html { render action: 'new' }
        format.json { render json: @purchase.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /purchasees/1
  # PATCH/PUT /purchasees/1.json
  def update
    respond_to do |format|
      if @purchase.update(purchase_params)
        format.html { redirect_to @purchase, notice: 'Purchase was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @purchase.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /purchasees/1
  # DELETE /purchasees/1.json
  def destroy
    @purchase.destroy
    respond_to do |format|
      format.html { redirect_to purchases_url }
      format.json { head :no_content }
    end
  end

  # PATCH /specifications/1
  def stock_in
    @stock_logs = []
    @purchase.purchase_details.each do |x|
      while x.amount > 0
        stock = Stock.get_available_stock(x.specification, @purchase.business, x.supplier, x.batch_no)
        
        stock_in_amount = stock.stock_in_amount(x.amount)
        x.amount -= stock_in_amount

        stock.save
        @stock_logs << StockLog.create(stock: stock, user: current_user, operation: StockLog::OPERATION[:purchase_stock_in], status: StockLog::STATUS[:waiting], object_class: x.class.to_s, object_primary_key: x.id, object_symbol: x.name, amount: x.amount, operation_type: StockLog::OPERATION_TYPE[:in])
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_purchase
      @purchase = Purchase.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def purchase_params
      params.require(:purchase).permit(:no, :name, :unit_id, :business_id, :amount, :sum, :desc,:status)
    end
end
