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
    
  end

  # GET /purchasees/1/edit
  def edit
  end

  # POST /purchasees
  # POST /purchasees.json
  def create
   # @purchase = Purchase.new(purchase_params)
    time=Time.new
    @purchase.unit = current_user.unit
    @purchase.status = Purchase::STATUS[:opened]
    @purchase.storage = current_storage
    @purchase.no=time.year.to_s+time.month.to_s.rjust(2,'0')+time.day.to_s.rjust(2,'0')+Purchase.count.to_s.rjust(5,'0')


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
    #@stock_logs = []
    Purchase.transaction do
      @purchase.purchase_details.each do |x|
        while x.waiting_amount > 0
          stock = Stock.get_available_stock(x.specification, x.supplier, @purchase.business, x.batch_no, current_storage)
          
          stock_in_amount = stock.stock_in_amount(x.waiting_amount)
          #x.amount -= stock_in_amount

          stock.save

          x.stock_logs.create(stock: stock, user: current_user, operation: StockLog::OPERATION[:purchase_stock_in], status: StockLog::STATUS[:waiting], purchase_detail: x, amount: stock_in_amount, operation_type: StockLog::OPERATION_TYPE[:in])
        end
      end
    end

    @stock_logs = @purchase.stock_logs
    @stock_logs_grid = initialize_grid(@stock_logs)
  end

  def check
    @stock_logs = @purchase.stock_logs
    @stock_logs_grid = initialize_grid(@stock_logs)
    respond_to do |format|
      if @purchase.check
        format.html { render action: 'stock_in' }
        format.json { head :no_content }
      else
        format.html { render action: 'stock_in', javascript: "alert('123')" }
        format.json { head :no_content }
      end
    end
  end

  def onecheck
    @stock_logs = @purchase.stock_logs
    @stock_logs_grid = initialize_grid(@stock_logs)
    StockLog.find(params[:stock_log]).check
    render action: 'stock_in'
  end


  def close
    respond_to do |format|
      if @purchase.close
        format.html { redirect_to purchases_url }
        format.json { head :no_content }
      else
        format.html { redirect_to purchases_url, javascript: "alert('123')" }
        format.json { head :no_content }
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
      params.require(:purchase).permit(:no, :name, :business_id, :amount, :sum, :desc)
    end
end
