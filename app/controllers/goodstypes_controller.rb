class GoodstypesController < ApplicationController
  load_and_authorize_resource

  # GET /goodstypes
  # GET /goodstypes.json
  def index
    @goodstypes = initialize_grid(@goodstypes)
  end

  # GET /goodstypes/1
  # GET /goodstypes/1.json
  def show
  end

  # GET /goodstypes/new
  def new
    @goodstype.unit_id = current_user.unit_id
    #@goodstype = Goodstype.new
  end

  # GET /goodstypes/1/edit
  def edit
  end

  # POST /goodstypes
  # POST /goodstypes.json
  def create
    #@goodstype = Goodstype.new(goodstype_params)

    respond_to do |format|
      if @goodstype.save
        format.html { redirect_to @goodstype, notice: 'Goodstype was successfully created.' }
        format.json { render action: 'show', status: :created, location: @goodstype }
      else
        format.html { render action: 'new' }
        format.json { render json: @goodstype.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /goodstypes/1
  # PATCH/PUT /goodstypes/1.json
  def update
    respond_to do |format|
      if @goodstype.update(goodstype_params)
        format.html { redirect_to @goodstype, notice: 'Goodstype was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @goodstype.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /goodstypes/1
  # DELETE /goodstypes/1.json
  def destroy
    @goodstype.destroy
    respond_to do |format|
      format.html { redirect_to goodstypes_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_goodstype
      @goodstype = Goodstype.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def goodstype_params
      params[:goodstype].permit!
    end
end
