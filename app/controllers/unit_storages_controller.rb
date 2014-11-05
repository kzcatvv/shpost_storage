class UnitStoragesController < ApplicationController
  load_and_authorize_resource :unit
  load_and_authorize_resource :storage, through: :unit, parent: false

  def index
  	#binding.pry
    # @storages = Storage.includes(:unit).where("storages.unit_id=?",current_user.unit_id)
    @storages_grid = initialize_grid(@storages)
  end

  # GET /storages/1
  # GET /storages/1.json
  def show
  	# @storage=Storage.find(params[:id])
  end

  # GET /storages/new
  def new
    # @storage = Storage.new
  end

  # GET /storages/1/edit
  def edit
      # @storage=Storage.find(params[:id])

  end

  # POST /storages
  # POST /storages.json
  def create

    # @storage = Storage.new(storage_params)
    # @storage.unit_id = u

    respond_to do |format|
      if @storage.save
        format.html { redirect_to unit_storage_path(@unit,@storage), notice: I18n.t('controller.create_success_notice', model: '单位')  }
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
     # @storage=Storage.find(params[:id])
     respond_to do |format|
      if @storage.update(storage_params)
        format.html { redirect_to unit_storage_path(@unit,@storage), notice: I18n.t('controller.update_success_notice', model: '单位') }
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
  	# @storage=Storage.find(params[:id])
    @storage.destroy
    respond_to do |format|
      format.html { redirect_to unit_storages_path(@unit) }
      format.json { head :no_content }
    end
  end

  def findstoragedtl
    @storages=Storage.where("unit_id=? ",params[:unitid])
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    #def set_storage
      #@storage = Role.find(params[:id])
    #end

    # Never trust parameters from the scary internet, only allow the white list through.
   # def storage_params
   #   params.require(:storage).permit( :user_id, :storage_id, :storage)
   #end
    def storage_params
      params.require(:storage).permit(:name, :desc, :default_storage)
    end

end
