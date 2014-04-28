class KeyclientorderdetailsController < ApplicationController
  #before_action :set_keyclientorderdetail, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource :keyclientorder
  load_and_authorize_resource :keyclientorderdetail, through: :keyclientorder, parent: false
  # GET /keyclientorderdetails
  # GET /keyclientorderdetails.json
  def index
    #@keyclientorderdetails = Keyclientorderdetail.all
    @keyclientorderdetails_grid = initialize_grid(@keyclientorderdetails)
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
    set_product_select(@keyclientorderdetail)
  end

  # POST /keyclientorderdetails
  # POST /keyclientorderdetails.json
  def create
    #@keyclientorderdetail = Keyclientorderdetail.new(keyclientorderdetail_params)
    
    respond_to do |format|
      if @keyclientorderdetail.save
        format.html { redirect_to keyclientorder_keyclientorderdetail_path(@keyclientorder,@keyclientorderdetail), notice: 'Keyclientorderdetail was successfully created.' }
        format.json { render action: 'show', status: :created, location: @keyclientorderdetail }
      else
        format.html { render action: 'new' }
        format.json { render json: @keyclientorderdetail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /keyclientorderdetails/1
  # PATCH/PUT /keyclientorderdetails/1.json
  def update
    respond_to do |format|
      if @keyclientorderdetail.update(keyclientorderdetail_params)
        @specification = Specification.find(params[:keyclientorderdetail][:specification_id])
        OrderDetail.where(order_id: @keyclientorder.orders).update_all(name: @specification.name,specification_id: params[:keyclientorderdetail][:specification_id],amount: params[:keyclientorderdetail][:amount],batch_no: params[:keyclientorderdetail][:batch_no],supplier_id: params[:keyclientorderdetail][:supplier_id])
        format.html { redirect_to keyclientorder_keyclientorderdetail_path(@keyclientorder,@keyclientorderdetail), notice: 'Keyclientorderdetail was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @keyclientorderdetail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /keyclientorderdetails/1
  # DELETE /keyclientorderdetails/1.json
  def destroy
    @keyclientorderdetail.destroy
    respond_to do |format|
      format.html { redirect_to keyclientorder_keyclientorderdetails_path(@keyclientorder) }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_keyclientorderdetail
      @keyclientorderdetail = Keyclientorderdetail.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def keyclientorderdetail_params
      params.require(:keyclientorderdetail).permit(:keyclientorder_id, :specification_id, :desc, :amount, :batch_no, :supplier_id)
    end
end
