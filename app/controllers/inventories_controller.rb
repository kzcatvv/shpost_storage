class InventoriesController < ApplicationController
  load_and_authorize_resource

  def index
    @inventories_grid = initialize_grid(@inventories)
  end

  def show
  end

  def new
    @area = Area.where("storage_id = ?",current_storage.id)
    @areas_grid = initialize_grid(Area,:name => 'g1',
      :conditions => {:storage_id => current_storage.id})

    @businesses_grid = initialize_grid(Business,:name => 'g2',
      :conditions => {:unit_id => current_storage.unit.id})

    @relationships_grid = initialize_grid(Relationship,:name => 'g3',
      :include => [:business,:supplier],
      :conditions => {"businesses.unit_id" => current_storage.unit.id,
                      "suppliers.unit_id" => current_storage.unit.id})
  end

  def edit
    @area = Area.where("storage_id = ?",current_storage.id)
    @areas_grid = initialize_grid(Area,:name => 'g1',
      :conditions => {:storage_id => current_storage.id})

    @businesses_grid = initialize_grid(Business,:name => 'g2',
      :conditions => {:unit_id => current_storage.unit.id})

    @relationships_grid = initialize_grid(Relationship,:name => 'g3',
      :include => [:business,:supplier],
      :conditions => {"businesses.unit_id" => current_storage.unit.id,
                      "suppliers.unit_id" => current_storage.unit.id})
  end

  def create
    if !params[:g1].nil?
      areads = params[:g1][:selected]
    end
    if !params[:g2].nil?
      goodds = params[:g2][:selected]
    end
    if !params[:g3].nil?
      goodds = params[:g3][:selected]
    end
    if !areads.blank?
      @inventory.inv_type_dtl = areads.join(",")
    end
    if !goodds.blank?
      @inventory.goods_inv_dtl = goodds.join(",")
    end
    @inventory.status = "opened"
    respond_to do |format|
      if @inventory.save
        format.html { redirect_to @inventory, notice: I18n.t('controller.create_success_notice', model: '盘点单') }
        format.json { render action: 'show', status: :created, location: @inventory }
      else
        format.html { render action: 'new' }
        format.json { render json: @inventory.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    if !params[:g1].nil?
      areads = params[:g1][:selected]
    end
    if !params[:g2].nil?
      goodds = params[:g2][:selected]
    end
    if !params[:g3].nil?
      goodds = params[:g3][:selected]
    end
    if !areads.blank?
      @inventory.inv_type_dtl = areads.join(",")
    end
    if !goodds.blank?
      @inventory.goods_inv_dtl = goodds.join(",")
    end

    respond_to do |format|
      if @inventory.update(inventory_params)
        format.html { redirect_to @inventory, notice: I18n.t('controller.update_success_notice', model: '盘点单')  }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @inventory.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @inventory.destroy
    respond_to do |format|
      format.html { redirect_to inventories_url }
      format.json { head :no_content }
    end
  end

  def inventorydetail
    @inventoryid = @inventory.id
    @stocks =  Stock.includes(:storage).where("storages.id = ? ",current_storage.id)
    if @inventory.status == "opened"
      if @inventory.inv_type == "byarea"
        areas=@inventory.inv_type_dtl.split(",")
        @stocks = @stocks.includes(:area).where("areas.id in (?)",areas)
      end
      if @inventory.goods_inv_type == "bybusiness"
        bus = @inventory.goods_inv_dtl.split(",")
        @stocks = @stocks.where("business_id in (?)",bus)
      elsif @inventory.goods_inv_type == "byrel"
        rels = @inventory.goods_inv_dtl.split(",")
        @stocks = @stocks.where("relationship_id in (?)",rels)
      end

      @stocks.each do |stock|
          @inventory.stock_logs.create(user: current_user ,stock: stock,status: StockLog::STATUS[:waiting], operation: StockLog::OPERATION[:inventory], operation_type: StockLog::OPERATION_TYPE[:reset], batch_no: stock.batch_no, expiration_date: stock.expiration_date, amount:stock.actual_amount)
      end
        
      @inventory.update(status: "inventoring")
    end
    @stock_logs = @inventory.stock_logs.where(operation_type: 'reset')
  end

  def find_shelf_stock
      # binding.pry
      @stocks = Stock.where(shelf_id: params[:shelf_id]).accessible_by(current_ability).map{|u| [u.batch_no+u.specification.full_title,u.id]}.insert(0,"请选择")
      @rowid = "stock_logs_invstockid_"+params[:row_id].to_s
      
      respond_to do |format|
        format.js 
      end
  end

  def find_stamt
    stock = Stock.where("shelf_id = ? and relationship_id = ?",params[:shelf_id],params[:rel_id]).first
    if stock.blank?
      @actual_amount = 0
    else
      @actual_amount = stock.actual_amount
    end
    render json: { actual_amount: @actual_amount }
  end

  def check
    @inventory = Inventory.find(params[:format])
    @stock_logs = @inventory.stock_logs
    @stock_logs_grid = initialize_grid(@stock_logs)

    if @inventory.status != "closed"
      if @inventory.check!
        redirect_to inventories_url 

      else
        redirect_to inventories_url
      end
    else
      flash[:alert] = "该盘点单已完成"
      redirect_to inventories_url
    end
  end

  def assign
    @tasker = Task.tasker_in_work(@inventory)
    @task_finished = !@inventory.has_waiting_stock_logs()
    @sorters = current_storage.get_sorter()
  end

  def assign_select
    if @inventory.has_waiting_stock_logs()
      Task.save_task(@inventory,current_storage.id,params[:assign_user])
    end
    render json: {}
  end

  private
    def set_inventory
      @inventory = Inventory.find(params[:id])
    end

    def inventory_params
      params.require(:inventory).permit(:no, :unit_id, :desc, :name, :inv_type, :storage_id, :barcode, :status, :goods_inv_type, :goods_inv_dtl)
    end
end
