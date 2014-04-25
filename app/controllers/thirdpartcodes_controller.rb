class ThirdpartcodesController < ApplicationController
  #before_action :set_thirdpartcode, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  # GET /thirdpartcodes
  # GET /thirdpartcodes.json
  def index
    #@thirdpartcodes = Thirdpartcode.all
    @thirdpartcodes_grid = initialize_grid(@thirdpartcodes)
  end

  # GET /thirdpartcodes/1
  # GET /thirdpartcodes/1.json
  def show
  end

  # GET /thirdpartcodes/new
  def new
    #@thirdpartcode = Thirdpartcode.new
  end

  # GET /thirdpartcodes/1/edit
  def edit
  end

  # POST /thirdpartcodes
  # POST /thirdpartcodes.json
  def create
    #@thirdpartcode = Thirdpartcode.new(thirdpartcode_params)
    #@thirdpartcode.specification_id = params[:specification_id][:id]
    respond_to do |format|
      if @thirdpartcode.save
        format.html { redirect_to @thirdpartcode, notice: 'Thirdpartcode was successfully created.' }
        format.json { render action: 'show', status: :created, location: @thirdpartcode }
      else
        format.html { render action: 'new' }
        format.json { render json: @thirdpartcode.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /thirdpartcodes/1
  # PATCH/PUT /thirdpartcodes/1.json
  def update
    respond_to do |format|
      if @thirdpartcode.update(thirdpartcode_params)
        format.html { redirect_to @thirdpartcode, notice: 'Thirdpartcode was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @thirdpartcode.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /thirdpartcodes/1
  # DELETE /thirdpartcodes/1.json
  def destroy
    @thirdpartcode.destroy
    respond_to do |format|
      format.html { redirect_to thirdpartcodes_url }
      format.json { head :no_content }
    end
  end


  def select_commodities
      #@objid = params[:object_id]

      @commodities = Commodity.where(goodstype_id: params[:goodstype_id]).collect{|c| [c.name,c.id]}.insert(0,"请选择")
      #binding.pry
      respond_to do |format|
        format.js 
      end

  end

  def select_specifications
      @objid = params[:object_id]+"_specification_id"
      @specifications = Specification.where(commodity_id: params[:commodity_id]).collect{|l| [l.name,l.id]}.insert(0,"请选择")
      #binding.pry
      respond_to do |format|
        format.js 
      end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_thirdpartcode
      @thirdpartcode = Thirdpartcode.find(params[:id])
    end

    

    # Never trust parameters from the scary internet, only allow the white list through.
    def thirdpartcode_params
      params.require(:thirdpartcode).permit(:business_id, :supplier_id, :specification_id, :external_code)
    end
end
