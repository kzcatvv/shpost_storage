class StoragesController < ApplicationController
  #before_action :set_storage, only: [:show, :edit, :update, :destroy]
  #before_action :find_unit, only: [:index, :show, :new, :edit, :create, :update, :destroy]
  load_and_authorize_resource :unit
  load_and_authorize_resource :storage, through: :unit, parent: false
  #skip_load_resource :storage, :only => :create

  # GET /units/1/storages/1/change
  def change
    session[:current_storage] = Storage.find(params[:id])
    redirect_to request.referer
  end

  # GET /storages
  # GET /storages.json
  def index
    #@storages = Storage.all
    @storages_grid = initialize_grid(@storages)
  end

  # GET /storages/1
  # GET /storages/1.json
  def show
    #@storage = @unit.storages.find(params[:id])
  end

  # GET /storages/new
  def new
    #@unit = Unit.find(params[:unit_id])
    #@storage = @unit.storages.build
  end

  # GET /storages/1/edit
  def edit
    #@storage = @unit.storages.find(params[:id])
  end

  # POST /storages
  # POST /storages.json
  def create
    #@unit = Unit.find(params[:unit_id])
    #@storage = @unit.storages.build(storage_params)

    respond_to do |format|
      if @storage.save
        format.html { redirect_to unit_storage_path(@unit,@storage), notice: 'Storage was successfully created.' }
        format.json { render action: 'show', status: :created, location: @storage }
      else
        format.html { render action: 'new' }
        format.json { render json: @storage.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /storages/1
  # PATCH/PUT /storages/1.json
  def update
    respond_to do |format|
      if @storage.update(storage_params)
        format.html { redirect_to unit_storage_path(@unit,@storage), notice: 'Storage was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @storage.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /storages/1
  # DELETE /storages/1.json
  def destroy
    @storage.destroy
    respond_to do |format|
      format.html { redirect_to unit_storages_path(@unit) }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_storage
      @storage = Storage.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def storage_params
      params.require(:storage).permit(:name, :desc, :default_storage)
    end
end
