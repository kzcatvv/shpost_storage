class StocksController < ApplicationController
  load_and_authorize_resource

  # GET /stocks
  # GET /stocks.json
  def index
    @stocks_grid = initialize_grid(@stocks,
      :order => 'stocks.id',
      :order_direction => 'desc',
      include: [:shelf, :specification, :business, :supplier])
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
        @stock_log = StockLog.create(user: current_user, stock: @stock, operation: 'create_stock', status: 'checked', operation_type: 'in', amount: @stock.actual_amount, checked_at: Time.now)
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
      # before_amount = @stock.actual_amount
      if @stock.update(stock_params)
        # if before_amount <= @stock.actual_amount
        #   operation_type = 'in'
        #   amount = @stock.actual_amount - before_amount
        # else
        #   operation_type = 'out'
        #   amount = before_amount - @stock.actual_amount
        # end
        @stock_log = StockLog.create(user: current_user, stock: @stock, operation: 'update_stock', status: 'checked', operation_type: 'reset', amount: @stock.actual_amount, checked_at: Time.now)

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
    @stock_log = StockLog.create(user: current_user, stock: @stock, operation: 'destroy_stock', status: 'checked', operation_type: 'out', amount: @stock.actual_amount, checked_at: Time.now)
    respond_to do |format|
      format.html { redirect_to stocks_url }
      format.json { head :no_content }
    end
  end

  def findstock

  end

  def getstock
    @stocks=[]
    if !params[:ex_code].empty?
      @relationship=Relationship.where("external_code=?",params[:ex_code]).first
      if @relationship.nil?
        @stocks=[]
      else
        @stocks=Stock.where("business_id=? and specification_id=? and supplier_id=?",@relationship.business_id,@relationship.specification_id,@relationship.supplier_id)
      end

    elsif !params[:sixnine_code].empty?
      @specification=Specification.where("sixnine_code=?",params[:sixnine_code]).first
      if @specification.nil?
          @stocks=[]
      else
          @stocks=Stock.where(specification_id: @specification)
      end
    else
      flash[:alert] = "输入69码或商品编码"
      redirect_to :action => 'findstock'
    end
    @allcnt={}
    @stocks.each do |s|
        product = [s.business_id,s.specification_id,s.supplier_id]
        warning_amount=Relationship.where("business_id=? and specification_id=? and supplier_id=?",s.business_id,s.specification_id,s.supplier_id).first.warning_amt

        if @allcnt.has_key?(product)
            @allcnt[product][0]=@allcnt[product][0]+s.actual_amount
            @allcnt[product][1]=@allcnt[product][1]+s.virtual_amount
        else
            @allcnt[product]=[s.actual_amount,s.virtual_amount,warning_amount]
        end
     end
   
    #binding.pry

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    # def set_stock
    #   @stock = Stock.find(params[:id])
    # end

    # Never trust parameters from the scary internet, only allow the white list through.
    def stock_params
      params.require(:stock).permit(:shelf_id,:batch_no, :business_id, :supplier_id, :purchase_detail_id, :specification_id, :actual_amount, :virtual_amount,:desc)
    end
end
