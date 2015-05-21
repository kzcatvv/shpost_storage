class AreasController < ApplicationController
  before_filter :find_current_storage
  load_and_authorize_resource :area

  def find_current_storage
    @areas = Area.where("storage_id = ?", current_storage.id)
  end

  # GET /areas
  # GET /areas.json
  def index
    @storage=current_storage
    if !@storage.need_pick
      @areas=@areas.where("area_type!='pick' or area_type is null")
    end
    @areas_grid = initialize_grid(@areas)
  end

  # GET /areas/1
  # GET /areas/1.json
  def show
  end

  # GET /areas/new
  def new
    @area.storage_id = current_storage.id
  end

  # GET /areas/1/edit
  def edit
  end

  # POST /areas
  # POST /areas.json
  def create
    # @area = Area.new(area_params)
    
    # area_code=@area.area_code 
    # if !area_code.blank?
    #   if !Area.accessible_by(current_ability).where(area_code:area_code).blank?
    #     flash[:alert] = "该区域编号已存在"
    #     redirect_to (new_area_path) and return
    #   end
    # end

    @area.storage_id = current_storage.id

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
          #shelf.update_attribute(:is_bad,@area.is_bad)
          shelf.update_attribute(:shelf_type,@area.area_type)
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
      #params.require(:area).permit(:name, :desc, :area_code, :is_bad)
      params.require(:area).permit(:name, :desc, :area_code, :area_type)
    end
end
