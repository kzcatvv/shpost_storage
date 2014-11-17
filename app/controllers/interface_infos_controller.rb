class InterfaceInfosController < ApplicationController
  load_and_authorize_resource
  before_action :set_interface_info, only: [:show, :edit, :update, :destroy]

  # GET /interface_infos
  # GET /interface_infos.json
  def index
    @interface_infos = InterfaceInfo.all
    @interface_infos_grid = initialize_grid(@interface_infos,
      :order => 'interface_infos.first_time',
      :order_direction => 'desc')
  end

  # GET /interface_infos/1
  # GET /interface_infos/1.json
  def show
  end

  # GET /interface_infos/new
  def new
    @interface_info = InterfaceInfo.new
  end

  # GET /interface_infos/1/edit
  def edit
  end

  # POST /interface_infos
  # POST /interface_infos.json
  def create
    @interface_info = InterfaceInfo.new(interface_info_params)

    respond_to do |format|
      if @interface_info.save
        format.html { redirect_to @interface_info, notice: 'Interface info was successfully created.' }
        format.json { render action: 'show', status: :created, location: @interface_info }
      else
        format.html { render action: 'new' }
        format.json { render json: @interface_info.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /interface_infos/1
  # PATCH/PUT /interface_infos/1.json
  def update
    respond_to do |format|
      if @interface_info.update(interface_info_params)
        format.html { redirect_to @interface_info, notice: 'Interface info was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @interface_info.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /interface_infos/1
  # DELETE /interface_infos/1.json
  def destroy
    @interface_info.destroy
    respond_to do |format|
      format.html { redirect_to interface_infos_url }
      format.json { head :no_content }
    end
  end

  def resend
    respond_to do |format|
      if InterfaceInfo.resend(params[:id]).eql? "0"
        
        format.html { redirect_to action: 'index' }
        format.json { head :no_content }
      else
        # @interface_infos = InterfaceInfo.all
        # @interface_infos_grid = initialize_grid(@interface_infos)
        format.html { redirect_to action: 'index' }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_interface_info
      @interface_info = InterfaceInfo.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def interface_info_params
      params.require(:interface_info).permit(:method_name, :class_name, :status, :operate_time, :url, :url_method, :url_content, :type)
    end
end
