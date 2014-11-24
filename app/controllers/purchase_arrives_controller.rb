class PurchaseArrivesController < ApplicationController
  # before_action :set_purchase_arrive, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource :purchase
  load_and_authorize_resource :purchase_detail, through: :purchase, parent: false
  load_and_authorize_resource :purchase_arrive, through: :purchase_detail, parent: false

  def index
    # @purchase_arrives = PurchaseArrive.all
    # respond_with(@purchase_arrives)
    @purchase_arrives_grid = initialize_grid(@purchase_arrives)

  end

  def show
    # respond_with(@purchase_arrive)
  end

  def new
    # @purchase_arrive = PurchaseArrive.new
    # respond_with(@purchase_arrive)
  end

  def edit
  end

  def create
    # @purchase_arrive = PurchaseArrive.new(purchase_arrive_params)
    # @purchase_arrife.save
    # respond_with(@purchase_arrive)
    respond_to do |format|
      if @purchase_arrive.save
        format.html { redirect_to purchase_purchase_detail_purchase_arrif_path(@purchase,@purchase_detail,@purchase_arrive), notice: I18n.t('controller.create_success_notice', model: '采购单到货明细') }
        format.json { render action: 'show', status: :created, location: @purchase_arrive }
      else
        format.html { render action: 'new' }
        format.json { render json: @purchase_arrive.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @purchase_arrife.update(purchase_arrive_params)
    respond_with(@purchase_arrive)
  end

  def destroy
    @purchase_arrife.destroy
    respond_with(@purchase_arrive)
  end

  private
    def set_purchase_arrive
      @purchase_arrive = PurchaseArrive.find(params[:id])
    end

    def purchase_arrive_params
      params.require(:purchase_arrive).permit(:arrived_amount, :expiration_date, :date, :arrived_date, :date, :batch_no, :string, :purchase_detail_id, :integer)
    end
end
