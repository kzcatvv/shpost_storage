class RelationshipsController < ApplicationController
  #before_action :set_relationship, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  # GET /relationships
  # GET /relationships.json
  def index
    #@relationships = Relationship.all
    @relationships_grid = initialize_grid(@relationships)
  end

  # GET /relationships/1
  # GET /relationships/1.json
  def show
  end

  # GET /relationships/new
  def new
    #@relationship = Relationship.new
  end

  # GET /relationships/1/edit
  def edit
    #binding.pry
  end

  # POST /relationships
  # POST /relationships.json
  def create
    #@relationship = Relationship.new(relationship_params)
    #@relationship.specification_id = params[:specification_id][:id]
    respond_to do |format|
      if @relationship.save
        format.html { redirect_to @relationship, notice: 'Relationship was successfully created.' }
        format.json { render action: 'show', status: :created, location: @relationship }
      else
        format.html { render action: 'new' }
        format.json { render json: @relationship.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /relationships/1
  # PATCH/PUT /relationships/1.json
  def update
    respond_to do |format|
      if @relationship.update(relationship_params)
        format.html { redirect_to @relationship, notice: 'Relationship was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @relationship.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /relationships/1
  # DELETE /relationships/1.json
  def destroy
    @relationship.destroy
    respond_to do |format|
      format.html { redirect_to relationships_url }
      format.json { head :no_content }
    end
  end


  def select_commodities
      #@objid = params[:object_id]

      @commodities = Commodity.where(goodstype_id: params[:goodstype_id]).accessible_by(current_ability).map{|u| [u.name,u.id]}.insert(0,"请选择")
      #binding.pry
      respond_to do |format|
        format.js 
      end

  end

  def select_specifications
      @objid = params[:object_id]+"_specification_id"
      @specifications = Specification.where(commodity_id: params[:commodity_id]).accessible_by(current_ability).map{|u| [u.name,u.id]}.insert(0,"请选择")
      #binding.pry
      respond_to do |format|
        format.js 
      end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_relationship
      @relationship = Relationship.find(params[:id])
    end

    

    # Never trust parameters from the scary internet, only allow the white list through.
    def relationship_params
      params.require(:relationship).permit(:business_id, :supplier_id, :specification_id, :external_code, :spec_desc)
    end
end
