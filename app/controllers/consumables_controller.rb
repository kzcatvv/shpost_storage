class ConsumablesController < ApplicationController
  load_and_authorize_resource

  def index
    @consumables_grid = initialize_grid(@consumables)
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
    @consumable.storage_id = current_storage.id
    @consumable.unit_id = current_storage.unit.id
    respond_to do |format|
      if @consumable.save
        #format.html { redirect_to @relationship, notice: I18n.t('controller.create_success_notice', model: '对应关系')}
        format.html { redirect_to @consumable, notice: I18n.t('controller.create_success_notice', model: '耗材')}
        format.json { render action: 'show', status: :created, location: @consumable }
      else
        format.html { render action: 'new' }
        format.json { render json: @consumable.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @consumable.storage_id = current_storage.id
    @consumable.unit_id = current_storage.unit.id
    respond_to do |format|
      if @consumable.update(consumable_params)

        format.html { redirect_to @consumable, notice: I18n.t('controller.update_success_notice', model: '耗材')}
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @consumable.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @consumable.destroy
    respond_to do |format|
      format.html { redirect_to consumables_url }
      format.json { head :no_content }
    end
  end

  private
    def set_consumable
      @consumable = Consumable.find(params[:id])
    end

    def consumable_params
      params.require(:consumable).permit(:business_id, :supplier_id, :name, :spec_desc, :unit_id, :storage_id)
    end
end
