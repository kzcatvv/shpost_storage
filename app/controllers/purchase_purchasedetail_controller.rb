class PurchasePurchasedetailController < ApplicationController
 # before_action :find_purchase_, only: [:index, :show, :new, :edit, :create, :update, :destroy]
  load_and_authorize_resource :purchase
  load_and_authorize_resource :purchase_detail, through: :purchase, parent: false
  #skip_load_resource :purchase_details, :only => :create

  # GET /purchase_detailss
  # GET /purchase_detailss.json
  def index
    #@purchase_detailss = User.all
    @purchase_details_grid = initialize_grid(@purchase_details)
  end

  # GET /purchase_detailss/1
  # GET /purchase_detailss/1.json
  def show
  end

  # GET /purchase_detailss/new
  def new
  end

  # GET /purchase_detailss/1/edit
  def edit
  end

  # POST /purchase_detailss
  # POST /purchase_detailss.json
  def create
    respond_to do |format|
      if @purchase_details.save
        format.html { redirect_to purchase__purchase_details_path(@purchase_,@purchase_details), notice: I18n.t('controller.create_success_notice', model: '用户采购单明细') }
        format.json { render action: 'show', status: :created, location: @purchase_details }
      else
        format.html { render action: 'new' }
        format.json { render json: @purchase_details.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /purchase_detailss/1
  # PATCH/PUT /purchase_detailss/1.json
  def update
    respond_to do |format|
      if @purchase_details.update(purchase_purchase_details_params)
        format.html { redirect_to purchase__purchase_details_path(@purchase_,@purchase_details), notice: I18n.t('controller.update_success_notice', model: '采购单明细') }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @purchase_details.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /purchase_detailss/1
  # DELETE /purchase_detailss/1.json
  def destroy
    @purchase_details.destroy
    respond_to do |format|
      format.html { redirect_to purchase__purchase_details_path(@purchase) }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    # def set_purchase_details
    #   @purchase_details = User.find(params[:id])
    # end

    # Never trust parameters from the scary internet, only allow the white list through.
    # def find_purchase_
    #   @purchase_ = Unit.find(params[:purchase__id])
    # end 
    
    def purchase_details_params
     params[:purchase_detail].permit(:purchase_detailsname, :name, :password, :email, :role)
    end 


end
