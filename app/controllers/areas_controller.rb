class AreasController < ApplicationController
  before_filter :find_current_storage
  load_and_authorize_resource :area

  def find_current_storage
    @areas = Area.where("storage_id = ?", session[:current_storage].id)
  end

  # GET /areas
  # GET /areas.json
  def index
    @areas_grid = initialize_grid(@areas)
  end

  # GET /areas/1
  # GET /areas/1.json
  def show
  end

  # GET /areas/new
  def new
    @area.storage_id = session[:current_storage].id
  end

  # GET /areas/1/edit
  def edit
  end

  # POST /areas
  # POST /areas.json
  def create
    # @area = Area.new(area_params)
    @area.storage_id = session[:current_storage].id

    respond_to do |format|
      if @area.save
        format.html { redirect_to @area, notice: I18n.t('controller.create_success_notice', model: '区域') }
        format.json { render action: 'show', status: :created, location: @area }
      else
        format.html { render action: 'new' }
        format.json { render json: @area.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /areas/1
  # PATCH/PUT /areas/1.json
  def update
    respond_to do |format|
      if @area.update(area_params)

        format.html { redirect_to @area, notice: I18n.t('controller.update_success_notice', model: '区域')}
        @area.shelves.each do |shelf|
          shelf.update_attribute(:is_bad,@area.is_bad)
        end
        format.html { redirect_to @area, notice: 'Area was successfully updated.' }

        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @area.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /areas/1
  # DELETE /areas/1.json
  def destroy
    @area.destroy
    respond_to do |format|
      format.html { redirect_to areas_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_area
      @area = Area.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def area_params
      params.require(:area).permit(:name, :desc, :area_code, :is_bad)
    end
end
