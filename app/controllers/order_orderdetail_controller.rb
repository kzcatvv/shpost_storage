class OrderOrderdetailController < ApplicationController
  # before_action :find_order, only: [:index, :show, :new, :edit, :create, :update, :destroy]
  load_and_authorize_resource :order
  load_and_authorize_resource :order_detail, through: :order, parent: false
  #skip_load_resource :order_detail, :only => :create

  # GET /order_details
  # GET /order_details.json
  def index
    #@order_details = User.all
    @order_details_grid = initialize_grid(@order_details)
  end

  # GET /order_details/1
  # GET /order_details/1.json
  def show
  end

  # GET /order_details/new
  def new
  end

  # GET /order_details/1/edit
  def edit
  end

  # POST /order_details
  # POST /order_details.json
  def create
    respond_to do |format|
      if @order_detail.save
        format.html { redirect_to order_order_detail_path(@order,@order_detail), notice: I18n.t('controller.create_success_notice', model: '定单明细') }
        format.json { render action: 'show', status: :created, location: @order_detail }
      else
        format.html { render action: 'new' }
        format.json { render json: @order_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /order_details/1
  # PATCH/PUT /order_details/1.json
  def update
    respond_to do |format|
      if @order_detail.update(orderorder_detail_params)
        format.html { redirect_to order_order_detail_path(@order,@order_detail), notice: I18n.t('controller.update_success_notice', model: '定单明细') }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @order_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /order_details/1
  # DELETE /order_details/1.json
  def destroy
    @order_detail.destroy
    respond_to do |format|
      format.html { redirect_to order_order_detail_path(@order) }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    # def set_order_detail
    #   @order_detail = User.find(params[:id])
    # end

    # Never trust parameters from the scary internet, only allow the white list through.
    # def find_order
    #   @order = Unit.find(params[:order_id])
    # end 
    
    def order_detail_params
      params[:order_detail].permit(:order_detailname, :name, :password, :email, :role)
    end 
end



