class StorageRolesController < ApplicationController
  load_and_authorize_resource :storage
  load_and_authorize_resource :role, through: :storage, parent: false

  # GET /roles
  # GET /roles.json
  def index
    @role_groups = @roles.group_by{|x| x.user_id}
  end

  # GET /roles/1
  # GET /roles/1.json
  def show
    # @role=Role.find(params[:id])
  end

  # GET /roles/new
  def new
    # @role = Role.new
  end

  # GET /roles/1/edit
  def edit
  end

  # POST /roles
  # POST /roles.json
  def create
    # @role.storage = @storage

    respond_to do |format|
      if @role.save
        format.html { redirect_to storage_roles_path(@storage), notice: 'Role was successfully created.' }
        format.json { render action: 'show', status: :created, location: @role }
      else
        format.html { render action: 'new' }
        format.json { render json: @role.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /roles/1
  # PATCH/PUT /roles/1.json
  def update

  end

  # DELETE /roles/1
  # DELETE /roles/1.json
  def destroy
    # @role=Role.find(params[:id])
    @role.destroy
    respond_to do |format|
      format.html { redirect_to storage_roles_path }
      format.js
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    #def set_role
      #@role = Role.find(params[:id])
    #end

    # Never trust parameters from the scary internet, only allow the white list through.
    def role_params
      params.require(:role).permit( :user_id, :role)
    end
end
