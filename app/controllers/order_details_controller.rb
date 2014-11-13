class OrderDetailsController < ApplicationController
  load_and_authorize_resource :order
  load_and_authorize_resource :order_detail, through: :order, parent: false

  # GET /order_detailes
  # GET /order_detailes.json
  def index
    @order_details_grid = initialize_grid(@order_details)
  end

  # GET /order_detailes/1
  # GET /order_detailes/1.json
  def show
  end

  # GET /order_detailes/new
  def new
   # @order_detail = OrderDetail.new
  end

  # GET /order_detailes/1/edit
  def edit
    set_autocom_update(@order_detail)
  end

  # POST /order_detailes
  # POST /order_detailes.json
  def create
   # @order_detail = OrderDetail.new(order_detail_params)

    respond_to do |format|
      if @order_detail.save
        format.html { redirect_to order_order_detail_path(@order,@order_detail), notice: I18n.t('controller.create_success_notice', model: '订单明细')}
        format.json { render action: 'show', status: :created, location: @order_detail }
      else
        format.html { render action: 'new' }
        format.json { render json: @order_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /order_detailes/1
  # PATCH/PUT /order_detailes/1.json
  def update
    respond_to do |format|
      if @order_detail.update(order_detail_params)
        format.html { redirect_to order_order_detail_path(@order,@order_detail), notice: I18n.t('controller.update_success_notice', model: '订单明细')}
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @order_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /order_detailes/1
  # DELETE /order_detailes/1.json
  def destroy
    @order_detail.destroy
    respond_to do |format|
      format.html { redirect_to order_order_details_path(@order) }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
   # def set_order_detail
   #   @order_detail = OrderDetail.find(params[:id])
  #  end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_detail_params
      params.require(:order_detail).permit(:name,:specification_id, :amount ,:price,:batch_no ,:supplier_id,:order_id,:desc)
    end
end
