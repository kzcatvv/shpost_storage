class PurchaseArrivalsController < ApplicationController
  # before_action :set_purchase_arrive, only: [:show, :edit, :update, :destroy]
  # load_and_authorize_resource :purchase
  load_and_authorize_resource :purchase_detail
  load_and_authorize_resource :purchase_arrival, through: :purchase_detail

  def index
    # @purchase_arrives = PurchaseArrive.all
    # respond_with(@purchase_arrives)
    # binding.pry
    @purchase_arrivals_grid = initialize_grid(@purchase_arrivals)

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
      if @purchase_arrival.save
        format.html { redirect_to purchase_detail_purchase_arrival_path(@purchase_detail,@purchase_arrival), notice: I18n.t('controller.create_success_notice', model: '采购单到货明细') }
        format.json { render action: 'show', status: :created, location: @purchase_arrival }
      else
        format.html { render action: 'new' }
        format.json { render json: @purchase_arrival.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    # @purchase_arrival.update(purchase_arrival_params)
    # respond_with(@purchase_arrival)
    respond_to do |format|
      if @purchase_arrival.update(purchase_arrival_params)
        format.html { redirect_to purchase_detail_purchase_arrival_path(@purchase_detail,@purchase_arrival), notice: I18n.t('controller.update_success_notice', model: '采购单到货明细')  }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @purchase_arrival.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    # @purchase_arrival.destroy
    # respond_with(@purchase_arrival)
    @purchase_arrival.destroy
    respond_to do |format|
      format.html { redirect_to purchase_detail_purchase_arrivals_path(@purchase_detail) }
      format.json { head :no_content }
    end
  end

  private
    def set_purchase_arrival
      @purchase_arrival = PurchaseArrival.find(params[:id])
    end

    def purchase_arrival_params
      params.require(:purchase_arrival).permit(:arrived_amount, :expiration_date, :arrived_at, :batch_no, :purchase_detail_id)
    end
end
