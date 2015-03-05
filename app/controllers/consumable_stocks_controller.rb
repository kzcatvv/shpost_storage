class ConsumableStocksController < ApplicationController
  load_and_authorize_resource

  def index
    @consumable_stocks_grid = initialize_grid(@consumable_stocks)
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
    @consumable_stock.storage_id = current_storage.id
    @consumable_stock.unit_id = current_storage.unit.id
    respond_to do |format|
      if @consumable_stock.save
        #format.html { redirect_to @relationship, notice: I18n.t('controller.create_success_notice', model: '对应关系')}
        format.html { redirect_to @consumable_stock, notice: I18n.t('controller.create_success_notice', model: '耗材库存')}
        format.json { render action: 'show', status: :created, location: @consumable_stock }
      else
        format.html { render action: 'new' }
        format.json { render json: @consumable_stock.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
  end

  def destroy
    @consumable_stock.destroy
    respond_to do |format|
      format.html { redirect_to consumable_stocks_url }
      format.json { head :no_content }
    end
  end

  def modconsumablestocks
    # binding.pry
    @consumable_stock = ConsumableStock.find(params[:format])
    @con_id = @consumable_stock.id
    unless request.get?

      if !params[:in_amt].blank?
        ConstockLog.create(user_id: current_user.id,consumable_stock_id: @consumable_stock.id,amount: params[:in_amt],operation_type: 'in')
        @consumable_stock.update(amount: @consumable_stock.amount + Integer(params[:in_amt]))
      end
      if !params[:out_amt].blank?
        ConstockLog.create(user_id: current_user.id,consumable_stock_id: @consumable_stock.id,amount: params[:out_amt],operation_type: 'out')
        @consumable_stock.update(amount: @consumable_stock.amount - Integer(params[:out_amt]))
      end
      flash[:alert] = "更新成功"
      redirect_to consumable_stocks_url     
    end

  end

  private
    def set_consumable_stock
      @consumable_stock = ConsumableStock.find(params[:id])
    end

    def consumable_stock_params
      params.require(:consumable_stock).permit(:consumable_id, :shelf_name, :amount)
    end
end
