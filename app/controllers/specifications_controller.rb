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

  def inoutlogs
    @inoutlogs_hash = {}
    @temp_hash = {}
    @stocklogs=StockLog.all
    operation=["in","out"]
    key_last=[]
    key_new=[]
    start_date=DateTime
    end_date=DateTime

    whereQuery = "storages.id=? and stock_logs.specification_id = ? and stock_logs.operation_type in (?)"
    
    if RailsEnv.is_oracle?
      date_condition = "to_char(stock_logs.created_at,'yyyymmdd')"
      # time = to_char(DateTime.parse(Time.now.to_s),'yyyymmdd')
    else
      date_condition = "strftime('%Y%m%d',stock_logs.created_at)"
    end
    time=DateTime.parse(Time.now.to_s).strftime('%Y-%m-%d').to_s

    
    if params[:sp_start_date].blank? or params[:sp_start_date]["sp_start_date"].blank?
      start_date = to_date(time.split(/-|\//)[0],(time.split(/-|\//)[1].to_i-1).to_s.rjust(2,'0'),time.split(/-|\//)[2])
    else 
      start_date = Date.civil(params[:sp_start_date]["sp_start_date"].split(/-|\//)[0].to_i,params[:sp_start_date]["sp_start_date"].split(/-|\//)[1].to_i,params[:sp_start_date]["sp_start_date"].split(/-|\//)[2].to_i)
    end
    
    if params[:sp_end_date].blank? or params[:sp_end_date]["sp_end_date"].blank?
      end_date = to_date(time.split(/-|\//)[0],time.split(/-|\//)[1],time.split(/-|\//)[2])
    else
      end_date = Date.civil(params[:sp_end_date]["sp_end_date"].split(/-|\//)[0].to_i,params[:sp_end_date]["sp_end_date"].split(/-|\//)[1].to_i,params[:sp_end_date]["sp_end_date"].split(/-|\//)[2].to_i)
    end
    
    @stocklogs=@stocklogs.where("stock_logs.created_at>=? and stock_logs.created_at<=?",start_date,(end_date+1))
        
    if !RailsEnv.is_oracle?    
      @temp_hash = @stocklogs.includes(:storage).where(whereQuery,current_storage.id,@specification.id,operation).group(:specification_id).group(:business_id).group(:supplier_id).group(date_condition).group(:operation_type).order(created_at: :desc).sum(:amount)
    else
      @temp_hash = @stocklogs.includes(:storage).where(whereQuery,current_storage.id,@specification.id,operation).group(:specification_id).group(:business_id).group(:supplier_id).group(date_condition).group(:operation_type).order("to_char(stock_logs.created_at,'yyyymmdd') desc").sum(:amount)
    end

    key_last[0] = ""
    key_last[1] = ""
    key_last[2] = ""
    key_last[3] = ""
    @temp_hash.each do |key,value|
      if !key[0].blank? and !key[1].blank? and !key[2].blank? and !key[3].blank?
        if key[0].eql?key_last[0] and key[1].eql?key_last[1] and key[2].eql?key_last[2] and key[3].eql?key_last[3]
          if key[4].eql?"in"
            @inoutlogs_hash[key_last][0]=value
          else
            @inoutlogs_hash[key_last][1]=value
          end
        else
          key_new = [key[0],key[1],key[2],key[3]]
          if key[4].eql?"in"
            @inoutlogs_hash[key_new]=[value,0]
          else
            @inoutlogs_hash[key_new]=[0,value]
          end
        end
        key_last = [key[0],key[1],key[2],key[3]]
      end
    end
    
  end


  def inoutlog_details
    key0=params[:key0]
    key1=params[:key1]
    key2=params[:key2]
    key3=params[:key3]
    operation=["in","out"]

    if RailsEnv.is_oracle?
      date_condition = "to_char(stock_logs.created_at,'yyyymmdd')"
    else
      date_condition = "strftime('%Y%m%d',stock_logs.created_at)"
    end

    @stock_logs = StockLog.accessible_by(current_ability).where("stock_logs.specification_id=? and stock_logs.business_id=? and stock_logs.supplier_id=? and "+date_condition+"=? and stock_logs.operation_type in (?)",key0,key1,key2,key3,operation)

    @stock_logs_grid = initialize_grid(@stock_logs,
      :order => 'stock_logs.created_at',
      :order_direction => 'desc')
  end

  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_specification
      @specification = Specification.find(params[:id])
    end

    def to_date(year,month,day)
      date = Date.civil(year.to_i,month.to_i,day.to_i)
      return date
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def specification_params
      params.require(:specification).permit( :sku, :sixnine_code, :desc, :name,:long,:wide,:high,:weight,:volume)
    end


end
