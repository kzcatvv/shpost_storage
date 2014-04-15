class KeyclientorderOrdersController < ApplicationController
  #before_action :set_keyclientorderdetail, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource :keyclientorder
  load_and_authorize_resource :order, through: :keyclientorder, parent: false
  # GET /keyclientorderdetails
  # GET /keyclientorderdetails.json
  def index
    #@keyclientorderdetails = Keyclientorderdetail.all
    @orders_grid = initialize_grid(@orders)
  end

  # GET /keyclientorderdetails/1
  # GET /keyclientorderdetails/1.json
  def show
  end

  # GET /keyclientorderdetails/new
  def new
    #@keyclientorderdetail = Keyclientorderdetail.new
  end

  # GET /keyclientorderdetails/1/edit
  def edit
  end

  # POST /keyclientorderdetails
  # POST /keyclientorderdetails.json
  def create
    #@keyclientorderdetail = Keyclientorderdetail.new(keyclientorderdetail_params)
    @order.order_type = Order::TYPE[:b2b]
    @order.status = Order::STATUS[:waiting]
    @order.unit = current_user.unit
    @order.storage = current_storage

    respond_to do |format|
      if @order.save
        @keyclientorderdetail = Keyclientorderdetail.where(keyclientorder_id: params[:keyclientorder_id])
        @keyclientorderdetail.each do |d|
           @specification = Specification.find(d.specification_id)
           @orderdetail= OrderDetail.create(name: @specification.name,specification: @specification, amount: d.amount, order: @order, batch_no: d.batch_no, supplier_id: d.supplier_id)
        end
        format.html { redirect_to keyclientorder_order_path(@keyclientorder,@order), notice: 'Order was successfully created.' }
        format.json { render action: 'show', status: :created, location: @order }
      else
        format.html { render action: 'new' }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /keyclientorderdetails/1
  # PATCH/PUT /keyclientorderdetails/1.json
  def update
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to keyclientorder_order_path(@keyclientorder,@order), notice: 'Order was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /keyclientorderdetails/1
  # DELETE /keyclientorderdetails/1.json
  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to keyclientorder_orders_path(@keyclientorder) }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    #def set_keyclientorderdetail
      #@keyclientorderdetail = Keyclientorderdetail.find(params[:id])
    #end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:no,:order_type, :need_invoice ,:customer_name,:customer_unit ,:customer_tel,:customer_phone,:customer_address,:customer_postcode,:customer_email,:total_weight,:total_price ,:total_amount,:transport_type,:transport_price,:pay_type,:status,:buyer_desc,:seller_desc,:business_id,:unit_id,:storage_id,:keyclientorder_id)
    end
end
