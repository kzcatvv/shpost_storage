class PurchaseDetailsController < ApplicationController
  load_and_authorize_resource

  # GET /purchase_detailes
  # GET /purchase_detailes.json
  def index
    @purchase_details_grid = initialize_grid(@purchase_details)
  end

  # GET /purchase_detailes/1
  # GET /purchase_detailes/1.json
  def show
  end

  # GET /purchase_detailes/new
  def new
    @purchase_detail = PurchaseDetail.new
  end

  # GET /purchase_detailes/1/edit
  def edit
  end

  # POST /purchase_detailes
  # POST /purchase_detailes.json
  def create
    @purchase_detail = PurchaseDetail.new(purchase_detail_params)

    respond_to do |format|
      if @purchase_detail.save
        format.html { redirect_to @purchase_detail, notice: 'Purchase was successfully created.' }
        format.json { render action: 'show', status: :created, location: @purchase_detail }
      else
        format.html { render action: 'new' }
        format.json { render json: @purchase_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /purchase_detailes/1
  # PATCH/PUT /purchase_detailes/1.json
  def update
    respond_to do |format|
      if @purchase_detail.update(purchase_detail_params)
        format.html { redirect_to @purchase_detail, notice: 'Purchase was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @purchase_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /purchase_detailes/1
  # DELETE /purchase_detailes/1.json
  def destroy
    @purchase_detail.destroy
    respond_to do |format|
      format.html { redirect_to purchase_details_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_purchase_detail
      @purchase_detail = PurchaseDetail.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def purchase_detail_params
      params.require(:purchase_detail).permit(:name,:purchase_id,:supplier_id,:spec_id,:qg_period,:batch_no,:amount,:sum,:desc,:status)
    end
end
