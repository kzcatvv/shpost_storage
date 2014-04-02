class PurchasedetailsController < ApplicationController
  load_and_authorize_resource

  # GET /purchasedetailes
  # GET /purchasedetailes.json
  def index
    @purchasedetails_grid = initialize_grid(@purchasedetails)
  end

  # GET /purchasedetailes/1
  # GET /purchasedetailes/1.json
  def show
  end

  # GET /purchasedetailes/new
  def new
    @purchasedetail = Purchasedetail.new
  end

  # GET /purchasedetailes/1/edit
  def edit
  end

  # POST /purchasedetailes
  # POST /purchasedetailes.json
  def create
    @purchasedetail = Purchasedetail.new(purchasedetail_params)

    respond_to do |format|
      if @purchasedetail.save
        format.html { redirect_to @purchasedetail, notice: 'Purchase was successfully created.' }
        format.json { render action: 'show', status: :created, location: @purchasedetail }
      else
        format.html { render action: 'new' }
        format.json { render json: @purchasedetail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /purchasedetailes/1
  # PATCH/PUT /purchasedetailes/1.json
  def update
    respond_to do |format|
      if @purchasedetail.update(purchasedetail_params)
        format.html { redirect_to @purchasedetail, notice: 'Purchase was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @purchasedetail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /purchasedetailes/1
  # DELETE /purchasedetailes/1.json
  def destroy
    @purchasedetail.destroy
    respond_to do |format|
      format.html { redirect_to purchasedetails_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_purchasedetail
      @purchasedetail = Purchasedetail.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def purchasedetail_params
      params.require(:purchasedetail).permit(:name,:purchase_id,:supplier_id,:spec_id,:qg_period,:batch_no,:amount,:sum,:desc,:status)
    end
end
