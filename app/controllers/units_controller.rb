class UnitsController < ApplicationController
  load_and_authorize_resource :unit

  # GET /units
  # GET /units.json
  def index
    #@unit = Unit.all
    @units_grid = initialize_grid(@units)
  end

  # GET /units/1
  # GET /units/1.json
  def show
  end

  # GET /units/new
  def new
    #@unit = Unit.new
  end

  # GET /units/1/edit
  def edit
  end

  # POST /units
  # POST /units.json
  def create
    respond_to do |format|
      if @unit.save
        set_default_storage
        format.html { redirect_to @unit, notice: 'Unit was successfully created.' }
        format.json { render action: 'show', status: :created, location: @unit }
      else
        format.html { render action: 'new' }
        format.json { render json: @unit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /units/1
  # PATCH/PUT /units/1.json
  def update
    respond_to do |format|
      if @unit.update(unit_params)
        set_default_storage
        format.html { redirect_to @unit, notice: 'Unit was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @unit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /units/1
  # DELETE /units/1.json
  def destroy
    @unit.destroy
    respond_to do |format|
      format.html { redirect_to units_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    #def set_unit
      #@unit = Unit.find(params[:id])
    #end
    def set_default_storage
       if @unit.storages.where("default_storage=?",true).empty?
          @defaultstorage=Storage.create(name: @unit.name+"仓库",desc: @unit.name+"仓库",unit: @unit,default_storage: true)
       end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def unit_params
      params.require(:unit).permit(:no, :name, :desc)
    end
end
