class ManualStockDetailsController < ApplicationController
  # before_action :set_manual_stock_detail, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource :manual_stock
  load_and_authorize_resource :manual_stock_detail, through: :manual_stock, parent: false

  # GET /manual_stock_details
  # GET /manual_stock_details.json
  def index
    @manual_stock_details_grid = initialize_grid(@manual_stock_details, order: 'created_at',order_direction: :desc)
  end

  # GET /manual_stock_details/1
  # GET /manual_stock_details/1.json
  def show
  end

  # GET /manual_stock_details/new
  def new
    # @manual_stock_detail = ManualStockDetail.new
  end

  # GET /manual_stock_details/1/edit
  def edit
    set_product_select(@manual_stock_detail)
  end

  # POST /manual_stock_details
  # POST /manual_stock_details.json
  def create
    # @manual_stock_detail = ManualStockDetail.new(manual_stock_detail_params)
    @manual_stock_detail.status = ManualStockDetail::STATUS[:waiting]
    respond_to do |format|
      if @manual_stock_detail.save
        format.html { redirect_to manual_stock_manual_stock_detail_path(@manual_stock,@manual_stock_detail), notice: 'Manual stock detail was successfully created.' }
        format.json { render action: 'show', status: :created, location: @manual_stock_detail }
      else
        format.html { render action: 'new' }
        format.json { render json: @manual_stock_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /manual_stock_details/1
  # PATCH/PUT /manual_stock_details/1.json
  def update
    respond_to do |format|
      if @manual_stock_detail.update(manual_stock_detail_params)
        format.html { redirect_to manual_stock_manual_stock_detail_path(@manual_stock,@manual_stock_detail), notice: 'Manual stock detail was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @manual_stock_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /manual_stock_details/1
  # DELETE /manual_stock_details/1.json
  def destroy
    @manual_stock_detail.destroy
    respond_to do |format|
      format.html { redirect_to manual_stock_manual_stock_details_path(@manual_stock)}
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_manual_stock_detail
      @manual_stock_detail = ManualStockDetail.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def manual_stock_detail_params
      params.require(:manual_stock_detail).permit(:name, :desc, :status, :amount, :manual_stock_id, :supplier_id, :specification_id)
    end
end
