class ShelvesController < ApplicationController
  # before_action :set_shelf, only: [:show, :edit, :update, :destroy]
  before_filter :find_current_storage
  load_and_authorize_resource :shelf

  autocomplete :shelf, :shelf_code

  def autocomplete_shelf_shelf_code
    term = params[:term]
    # brand_id = params[:brand_id]
    # country = params[:country]
    shelves = Shelf.where(area_id: Area.where(storage: current_storage).ids).where('shelf_code LIKE ?', "%#{term}%").order(:shelf_code).all
    render :json => shelves.map { |shelf| {:id => shelf.id, :label => shelf.shelf_code, :value => shelf.shelf_code} }
  end

  def find_current_storage
    @areas = Area.where("storage_id = ?", session[:current_storage].id)
    @shelves = Shelf.where("area_id in (?)", @areas.ids)
  end

  # GET /shelves
  # GET /shelves.json
  def index
    @shelves_grid = initialize_grid(@shelves,:include => :area)
  end

  # GET /shelves/1
  # GET /shelves/1.json
  def show
  end

  # GET /shelves/new
  def new
  end

  # GET /shelves/1/edit
  def edit
  end

  # POST /shelves
  # POST /shelves.json
  def create
    @shelf = Shelf.new(shelf_params)
    @shelf.shelf_code = @areas.find(shelf_params[:area_id]).area_code
    @shelf.shelf_code << "-" << change(shelf_params[:area_length])
    @shelf.shelf_code << "-" << change(shelf_params[:area_width])
    @shelf.shelf_code << "-" << change(shelf_params[:area_height])
    @shelf.shelf_code << "-" << change(shelf_params[:shelf_row])
    @shelf.shelf_code << "-" << change(shelf_params[:shelf_column])

    respond_to do |format|
      if @shelf.save
        format.html { redirect_to @shelf, notice: 'Shelf was successfully created.' }
        format.json { render action: 'show', status: :created, location: @shelf }
      else
        format.html { render action: 'new' }
        format.json { render json: @shelf.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /shelves/1
  # PATCH/PUT /shelves/1.json
  def update
    @shelf.shelf_code = @areas.find(shelf_params[:area_id]).area_code
    @shelf.shelf_code << "-" << change(shelf_params[:area_length])
    @shelf.shelf_code << "-" << change(shelf_params[:area_width])
    @shelf.shelf_code << "-" << change(shelf_params[:area_height])
    @shelf.shelf_code << "-" << change(shelf_params[:shelf_row])
    @shelf.shelf_code << "-" << change(shelf_params[:shelf_column])
    
    respond_to do |format|
      if @shelf.update(shelf_params)
        format.html { redirect_to @shelf, notice: 'Shelf was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @shelf.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shelves/1
  # DELETE /shelves/1.json
  def destroy
    @shelf.destroy
    respond_to do |format|
      format.html { redirect_to shelves_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_shelf
      @shelf = Shelf.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def shelf_params
      params.require(:shelf).permit(:area_id, :shelf_code, :desc, :area_length, :area_width, :area_height, :shelf_row, :shelf_column, :max_weight, :max_volume)
    end

    def change(text)
      str_space = "%02s" % text
      str_0 = str_space.tr(" ","0");
      if str_0.nil?
        str_space
      else
        str_0
      end
    end
end
