class UnitGoodstypesController < ApplicationController
	before_action :set_unit

  # GET /suppliers
  # GET /suppliers.json
  def index
    @goodstypes = initialize_grid(@unit.goodstypes)
  end

  # GET /suppliers/1
  # GET /suppliers/1.json
  def show
  	@goodstype = @unit.goodstypes.find( params[:id] )
  end

  # GET /suppliers/new
  def new
    @goodstype = @unit.goodstypes.build
  end

  # GET /suppliers/1/edit
  def edit
  	@goodstype = @unit.goodstypes.find( params[:id] )
  end

  # POST /suppliers
  # POST /suppliers.json
  def create
    @goodstype = @unit.goodstypes.build(params[:goodstype])
    if @goodstype.save
    	redirect_to unit_goodstypes_url( @unit )
    else
    	render :action => :new
    end
  end

  # PATCH/PUT /suppliers/1
  # PATCH/PUT /suppliers/1.json
  def update
    @goodstype = @unit.goodstypes.find( params[:id] )
    if @goodstype.update_attributes( params[:goodstype] )
    	redirect_to unit_goodstypes_url( @unit )
    else
    	render :action => :new
    end
  end

  # DELETE /suppliers/1
  # DELETE /suppliers/1.json
  def destroy
    @goodstype = @unit.goodstypes.find( params[:id] )
    @goodstype.destroy
    redirect_to unit_goodstypes_url( @unit )
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_unit
      params.permit!
      @unit = Unit.find(params[:unit_id])
    end
end
