class SpecificationsController < ApplicationController
  #before_action :set_specification, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource :commodity
  load_and_authorize_resource :specification, through: :commodity, parent: false

  # GET /specifications
  # GET /specifications.json
  def index
    #@specifications = Specification.all
    @specifications_grid = initialize_grid(@specifications, include: :commodity)

  end

  # GET /specifications/1
  # GET /specifications/1.json
  def show
  end

  # GET /specifications/new
  def new
    #@specification = Specification.new
  end

  # GET /specifications/1/edit
  def edit
  end

  # POST /specifications
  # POST /specifications.json
  def create
    #@specification = Specification.new(specification_params)
    @specification.all_name=Commodity.find(@specification.commodity_id).name+@specification.name

    respond_to do |format|
      if @specification.save
        # @specification.update_attribute(:sku,Commodity.find(@specification.commodity_id).goodstype_id.to_s + @specification.commodity_id.to_s + @specification.id.to_s) 
        format.html { redirect_to commodity_specification_path(@commodity,@specification), notice: I18n.t('controller.create_success_notice', model: '商品规格') }
        format.json { render action: 'show', status: :created, location: @specification }
      else
        format.html { render action: 'new' }
        format.json { render json: @specification.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /specifications/1
  # PATCH/PUT /specifications/1.json
  def update
    # @specification.all_name=Commodity.find(@specification.commodity_id).name+@specification.name
    respond_to do |format|
      if @specification.update(specification_params)
        # @specification.update_attribute(:sku,Commodity.find(@specification.commodity_id).goodstype_id.to_s + @specification.commodity_id.to_s + @specification.id.to_s)
        format.html { redirect_to commodity_specification_path(@commodity,@specification), notice: I18n.t('controller.update_success_notice', model: '商品规格') }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @specification.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /specifications/1
  # DELETE /specifications/1.json
  def destroy
    @specification.destroy
    respond_to do |format|
      format.html { redirect_to commodity_specifications_path(@commodity) }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_specification
      @specification = Specification.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def specification_params
      params.require(:specification).permit( :sku, :sixnine_code, :desc, :name,:long,:wide,:high,:weight,:volume)
    end
end
