class LogisticsController < ApplicationController
  load_and_authorize_resource :logistic

  def index
    @logistics_grid = initialize_grid(@logistics)
  end

  def show
    # respond_with(@logistic)
  end

  def new
    # @logistic = Logistic.new
    # respond_with(@logistic)
  end

  def edit
  end

  def create
    respond_to do |format|
      if @logistic.save
        format.html { redirect_to @logistic, notice: I18n.t('controller.create_success_notice', model: '物流')}
        format.json { render action: 'show', status: :created, location: @logistic }
      else
        format.html { render action: 'new' }
        format.json { render json: @logistic.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @logistic.update(logistic_params)
        format.html { redirect_to @logistic, notice: I18n.t('controller.update_success_notice', model: '物流') }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @logistic.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @logistic.destroy
    respond_to do |format|
      format.html { redirect_to logistics_url }
      format.json { head :no_content }
    end
  end

  private
    def set_logistic
      @logistic = Logistic.find(params[:id])
    end

    def logistic_params
      params.require(:logistic).permit(:name, :print_format, :is_getnum, :contact, :address, :contact_phone, :post, :is_default, :storage_id, :param_val1, :param_val2)
    end
end
