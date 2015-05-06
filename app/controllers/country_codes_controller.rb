class CountryCodesController < ApplicationController
  load_and_authorize_resource :country_code

  def index
    @country_codes_grid = initialize_grid(@country_codes)
  end

  def show
    # respond_with(@country_code)
  end

  def new
    # @country_code = CountryCode.new
    # respond_with(@country_code)
  end

  def edit
  end

  def create
    respond_to do |format|
      if @country_code.save
        format.html { redirect_to @country_code, notice: I18n.t('controller.create_success_notice', model: '国家代码')}
        format.json { render action: 'show', status: :created, location: @country_code }
      else
        format.html { render action: 'new' }
        format.json { render json: @country_code.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @country_code.update(country_code_params)
        format.html { redirect_to @country_code, notice: I18n.t('controller.update_success_notice', model: '国家代码') }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @country_code.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @country_code.destroy
    respond_to do |format|
      format.html { redirect_to country_codes_url }
      format.json { head :no_content }
    end
  end

  private
    def set_country_code
      @country_code = CountryCode.find(params[:id])
    end

    def country_code_params
      params.require(:country_code).permit(:chinese_name, :english_name, :code, :surfmail_partition_no, :regimail_partition_no, :is_mail)
    end
end
