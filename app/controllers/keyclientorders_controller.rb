class KeyclientordersController < ApplicationController
  #before_action :set_keyclientorder, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  # GET /keyclientorders
  # GET /keyclientorders.json
  def index
    #@keyclientorders = Keyclientorder.all
    @keyclientorders_grid = initialize_grid(@keyclientorders,
                   :order => 'keyclientorders.id',
                   :order_direction => 'desc',
                   include: [:business, :storage, :unit])
  end

  # GET /keyclientorders/1
  # GET /keyclientorders/1.json
  def show
  end

  # GET /keyclientorders/new
  def new
    #@keyclientorder = Keyclientorder.new
  end

  # GET /keyclientorders/1/edit
  def edit
  end

  # POST /keyclientorders
  # POST /keyclientorders.json
  def create
    #@keyclientorder = Keyclientorder.new(keyclientorder_params)
     @keyclientorder.unit = current_user.unit
     @keyclientorder.storage = current_storage
    respond_to do |format|
      if @keyclientorder.save
        format.html { redirect_to @keyclientorder, notice: 'Keyclientorder was successfully created.' }
        format.json { render action: 'show', status: :created, location: @keyclientorder }
      else
        format.html { render action: 'new' }
        format.json { render json: @keyclientorder.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /keyclientorders/1
  # PATCH/PUT /keyclientorders/1.json
  def update
    respond_to do |format|
      if @keyclientorder.update(keyclientorder_params)
        format.html { redirect_to @keyclientorder, notice: 'Keyclientorder was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @keyclientorder.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /keyclientorders/1
  # DELETE /keyclientorders/1.json
  def destroy
    @keyclientorder.destroy
    respond_to do |format|
      format.html { redirect_to keyclientorders_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    #def set_keyclientorder
      #@keyclientorder = Keyclientorder.find(params[:id])
    #end

    # Never trust parameters from the scary internet, only allow the white list through.
    def keyclientorder_params
      params.require(:keyclientorder).permit(:keyclient_name, :keyclient_addr, :contact_person, :phone, :desc, :batch_no, :unit_id, :storage_id, :business_id)
    end
end
