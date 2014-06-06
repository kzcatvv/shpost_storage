class OrderreturnsController < ApplicationController
  load_and_authorize_resource
  #before_action :set_orderreturn, only: [:show, :edit, :update, :destroy]

  # GET /orderreturns
  # GET /orderreturns.json
  def index
    @orderreturns = Orderreturn.all
  end

  # GET /orderreturns/1
  # GET /orderreturns/1.json
  def show
  end

  # GET /orderreturns/new
  def new
    @orderreturn = Orderreturn.new
  end

  # GET /orderreturns/1/edit
  def edit
  end

  # POST /orderreturns
  # POST /orderreturns.json
  def create
    @orderreturn = Orderreturn.new(orderreturn_params)

    respond_to do |format|
      if @orderreturn.save
        format.html { redirect_to @orderreturn, notice: 'Orderreturn was successfully created.' }
        format.json { render action: 'show', status: :created, location: @orderreturn }
      else
        format.html { render action: 'new' }
        format.json { render json: @orderreturn.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orderreturns/1
  # PATCH/PUT /orderreturns/1.json
  def update
    respond_to do |format|
      if @orderreturn.update(orderreturn_params)
        format.html { redirect_to @orderreturn, notice: 'Orderreturn was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @orderreturn.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orderreturns/1
  # DELETE /orderreturns/1.json
  def destroy
    @orderreturn.destroy
    respond_to do |format|
      format.html { redirect_to orderreturns_url }
      format.json { head :no_content }
    end
  end

  def packreturn
    @order_details=[]
  end

  def findtrackingnumber
    @order=Order.where(tracking_number: params[:tracking_number]).first
    @order_details=@order.order_details
    respond_to do |format|
          format.js 
    end

  end

  def doreturn
    sklogs=[]
    time = Time.now
    @batchid = time.year.to_s + time.month.to_s.rjust(2,'0') + time.day.to_s.rjust(2,'0') + (Orderreturn.select(:batch_id).distinct.count+1).to_s.rjust(5,'0')
    params[:cbids].each do |id|
      reason=params[("rereason_"+id).to_sym]
      isbad=params[("st_"+id).to_sym]
      if isbad == "否"
        @orderdtl=OrderDetail.find(id)
        @order=@orderdtl.order
        @orderreturn=Orderreturn.where(order_detail: @orderdtl).first
        if @orderreturn.nil?
          @orderreturn=Orderreturn.create(order_detail:@orderdtl,return_reason:reason,is_bad:isbad,batch_id:@batchid,status:"waiting")
        end
        stock=Stock.find_stock_in_storage(Specification.find(@orderdtl.specification_id),Supplier.find(@orderdtl.supplier_id),Business.find(@order.business_id),current_storage)
        stklog=StockLog.create(stock: stock, user: current_user, operation: StockLog::OPERATION[:order_return], status: StockLog::STATUS[:waiting], amount: @orderdtl.amount, operation_type: StockLog::OPERATION_TYPE[:in])
        @orderdtl.stock_logs << stklog
        sl=StockLog.where(id: stklog)
        sklogs += sl
      end
    end
    @stock_logs = StockLog.where(id: sklogs)

    @stock_logs_grid = initialize_grid(@stock_logs)
  end

  def returncheck

      @orderreturns=Orderreturn.where("batch_id=? and is_bad='否'",params[:format])
      @orderreturns.each do |ot|
        @orderdtl=OrderDetail.find(ot.order_detail_id)
        stlogs=@orderdtl.stock_logs.where("operation='order_return'")
        stlogs.each do |stlog|
          stlog.order_check
        end
        ot.return_in
      end
      

      redirect_to :action => 'packreturn'

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_orderreturn
      @orderreturn = Orderreturn.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def orderreturn_params
      params.require(:orderreturn).permit(:order_detail_id, :return_reason, :is_bad)
    end
end
