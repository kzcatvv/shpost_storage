class RolesController < ApplicationController
  #before_action :set_role, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource :user
  load_and_authorize_resource :role, through: :user, parent: false
  # GET /roles
  # GET /roles.json
  def index
    #@roles = Role.all
    @roles_grid = initialize_grid(@roles)
  end

  # GET /roles/1
  # GET /roles/1.json
  def show
  end

  # GET /roles/new
  def new
    #@role = Role.new
  end

  # GET /roles/1/edit
  def edit
  end

  # POST /roles
  # POST /roles.json
  def create
    #@role = Role.new(role_params)

    respond_to do |format|
      if @role.save
        format.html { redirect_to user_role_path(@user,@role), notice: 'Role was successfully created.' }
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
    respond_to do |format|
      if @role.update(role_params)
        format.html { redirect_to user_role_path(@user,@role), notice: 'Role was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @role.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /roles/1
  # DELETE /roles/1.json
  def destroy
    @role.destroy
    respond_to do |format|
      format.html { redirect_to user_roles_path(@user) }
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
      params.require(:role).permit( :storage_id, :role)
    end
end
