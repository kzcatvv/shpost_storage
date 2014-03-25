class UnitSuppliersController < ApplicationController
	before_action :set_unit

  # GET /suppliers
  # GET /suppliers.json
  def index
    @suppliers = @unit.suppliers
  end

  # GET /suppliers/1
  # GET /suppliers/1.json
  def show
  	@supplier = @unit.suppliers.find( params[:id] )
  end

  # GET /suppliers/new
  def new
    @supplier = @unit.suppliers.build
  end

  # GET /suppliers/1/edit
  def edit
  	@supplier = @unit.suppliers.find( params[:id] )
  end

  # POST /suppliers
  # POST /suppliers.json
  def create
    @supplier = @unit.suppliers.build(params[:supplier])
    if @supplier.save
    	redirect_to unit_suppliers_url( @unit )
    else
    	render :action => :new
    end
  end

  # PATCH/PUT /suppliers/1
  # PATCH/PUT /suppliers/1.json
  def update
    @supplier = @unit.suppliers.find( params[:id] )
    if @supplier.update_attributes( params[:supplier] )
    	redirect_to unit_suppliers_url( @unit )
    else
    	render :action => :new
    end
  end

  # DELETE /suppliers/1
  # DELETE /suppliers/1.json
  def destroy
    @supplier = @unit.suppliers.find( params[:id] )
    @supplier.destroy
    redirect_to unit_suppliers_url( @unit )
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_unit
      @unit = Unit.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def unit_params
      params.require(:unit).permit!
    end
end
