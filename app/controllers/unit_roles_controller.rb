class UnitRolesController < ApplicationController
  load_and_authorize_resource :role

  def index
  	#binding.pry
    @roles = Role.includes(:storage).where("storages.unit_id=?",current_user.unit_id)
    @userstoragerole={}
    @roles.each do |r|
       userstorage=[r.user_id,r.storage_id]
       if @userstoragerole.has_key?(userstorage)
            @userstoragerole[userstorage].push(r.role)
       else
            @userstoragerole[userstorage]=[r.role]
       end
    end
  end

  # GET /roles/1
  # GET /roles/1.json
  def show
  	@role=Role.find(params[:id])
  end

  # GET /roles/new
  def new
    @role = Role.new
  end

  # GET /roles/1/edit
  def edit
  end

  # POST /roles
  # POST /roles.json
  def create
    @role = Role.new(role_params)

    respond_to do |format|
      if @role.save
        format.html { redirect_to role_path(@role), notice: 'Role was successfully created.' }
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
  	@role=Role.find(params[:id])
    @role.destroy
    respond_to do |format|
      format.html { redirect_to roles_path }
      format.json { head :no_content }
    end
  end

  def findroledtl
    @roles=Role.where("user_id=? and storage_id=?",params[:usrid],params[:stid])
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    #def set_role
      #@role = Role.find(params[:id])
    #end

    # Never trust parameters from the scary internet, only allow the white list through.
    def role_params
      params.require(:role).permit( :user_id, :storage_id, :role)
    end
end
