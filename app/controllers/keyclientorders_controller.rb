class KeyclientordersController < ApplicationController
  #before_action :set_keyclientorder, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  # GET /keyclientorders
  # GET /keyclientorders.json
  def index
    #@keyclientorders = Keyclientorder.all
    @keyclientorders_grid = initialize_grid(@keyclientorders,
                   :conditions => ['order_type <> ?',"b2b"],
                   :order => 'keyclientorders.created_at',
                   :order_direction => 'desc',
                   include: [:business, :storage, :unit])
  end

  def b2bindex
    @keyclientorders_grid = initialize_grid(@keyclientorders,
                   :conditions => {:order_type => "b2b"},
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

  def pdjs
    Rails.logger.info "pdjs start"
    pdjs = TcbdSoap.new
    result = pdjs.order_enter(StorageConfig.config["tcsd"]["order_enter"]["uri"],StorageConfig.config["tcsd"]["order_enter"]["method"],@keyclientorder.id)
    Rails.logger.info result
    if result[0] > 0
      flash[:notice] = result[1]
    else
      flash[:alert] = result[1]
    end
    Rails.logger.info "pdjs end"
    redirect_to keyclientorder_orders_url(@keyclientorder)

  end

  def b2bstockout
      #binding.pry
      @keyclientorder = Keyclientorder.find(params[:format])
      Stock.order_stock_out(@keyclientorder, current_user)
      @keyclientorder.picking_out
      @stock_logs = @keyclientorder.stock_logs
      @stock_logs_grid = initialize_grid(@stock_logs)
  end

  def b2boutcheck

    @keyclientorder=Keyclientorder.find(params[:format])
    @scanspecification = ""

    stock_logs = @keyclientorder.stock_logs
    stock_logs.each do |stlog|
      stlog.check!
    end

    @keyclientorder.check_out

    redirect_to "/keyclientorders/b2bindex"

  end

  def b2bordersplit
      @keyclientorder=Keyclientorder.find(params[:format])
      @keyco=@keyclientorder.id
      @key_details_hash = @keyclientorder.orders.first.order_details.includes(:order).group(:specification_id, :supplier_id, :business_id, :storage_id).sum(:amount)
      ors = @keyclientorder.orders.where("is_split = ?",true)
      @scanall = OrderDetail.where(order_id: ors).includes(:order).group(:specification_id, :supplier_id, :business_id, :storage_id).sum(:amount)
      @dtl_cnt = @key_details_hash.length
      @act_cnt = 0
      # @order=@keyclientorder.orders.first
  end

  def b2bfind69code

    @scanspecification = Specification.where("sixnine_code = ?",params[:sixninecode]).first

    if @scanspecification.nil?
       @curr_sp=0
       @curr_sixnine=0
       @curr_der=1
    else
       @keyclientorder=Keyclientorder.find(params[:keyco])
       si = @keyclientorder.details.select(:specification_id)
       sncodes=Specification.where(id: si).where("sixnine_code = ?",params[:sixninecode])
       if sncodes.blank?
        @curr_der=1
       else
        @curr_der=0
       end
       @curr_sp=@scanspecification.id
       @curr_sixnine=@scanspecification.sixnine_code
    end

    respond_to do |format|
      format.js 
    end
  end

  def b2bsplitanorder
    @keyclientorder = Keyclientorder.find(params[:keyco])
    parentorder = @keyclientorder.orders.first
    childorder = parentorder.children.create(order_type: "b2c",customer_name: parentorder.customer_name,transport_type: parentorder.transport_type,status: parentorder.status,business_id: parentorder.business_id,unit_id: parentorder.unit_id,storage_id: parentorder.storage_id,keyclientorder_id: parentorder.keyclientorder_id,is_split: true,customer_name: parentorder.customer_name,customer_unit: parentorder.customer_unit,customer_tel: parentorder.customer_tel,customer_phone: parentorder.customer_phone,customer_address: parentorder.customer_address,customer_postcode: parentorder.customer_postcode,province: parentorder.province,city: parentorder.city,county: parentorder.county)
    ods = parentorder.order_details
    ods.each do |od|
      curr_specification = Specification.find(od.specification_id)
      scanlabal = "scancuram_" + curr_specification.sixnine_code
      if Integer(params[scanlabal.to_sym]) > 0
        childorder.order_details.create(name: od.name,specification_id: od.specification_id,amount: params[scanlabal.to_sym],batch_no: od.batch_no,supplier_id: od.supplier_id)
      end
    end
    #binding.pry
    @order_details = childorder.order_details
    @order = childorder

    respond_to do |format|
      format.js 
    end
  end

  def b2bsettrackingnumber
    @curr_or = Order.find(params[:split_order])
    @curr_or.update_attribute(:tracking_number,params[:split_tracking_num])
    @curr_or.b2bsetsplitstatus
    respond_to do |format|
      format.js 
    end
  end

  def ordercheck

    @keyclientorder=Keyclientorder.find(params[:format])
    @keyclientorder.check!
    
#     @orders=@keyclientorder.orders
# # b2c
#     @orders.each do |order|
#       order.stock_logs.each do |stlog|
#         stlog.check!
#       end
#       order.stock_out
#     end
#     #b2b
#     if !@keyclientorder.keyclientorderdetails.blank?
#       stock_logs = StockLog.where(keyclientorderdetail_id: @keyclientorder.keyclientorderdetails)
#       stock_logs.each do |stlog|
#         stlog.check!
#       end
#     end

    if @keyclientorder.keyclient_name == "auto"
      redirect_to '/orders/findprintindex'
    else
      redirect_to "/keyclientorders"
    end
  end

  def stockout
    begin
    Order.transaction do
      # @keyclientorder = Keyclientorder.find(params[:format])

      needpick = current_storage.need_pick

      if needpick
        Stock.pick_stock_out(@keyclientorder, current_user)

        @stock_logs = @keyclientorder.stock_logs.where(" operation_type = 'out' ")
      else

        Stock.order_stock_out(@keyclientorder, current_user)

        @keyclientorder.orders.each do |order|
          order.set_picking
        end
      
        @stock_logs = @keyclientorder.stock_logs
      end
        @stock_logs_grid = initialize_grid(@stock_logs)
    end
    rescue Exception => e
      Rails.logger.error e.backtrace
      flash[:alert] = e.message
      redirect_to '/orders/findprintindex'
      # raise ActiveRecord::Rollback
    end
  end

  def assign
    @tasker = Task.tasker_in_work(@keyclientorder)
    @task_finished = !@keyclientorder.has_waiting_stock_logs()
    @sorters = current_storage.get_sorter()
  end

  def assign_select
    if @keyclientorder.has_waiting_stock_logs()
      Task.save_task(@keyclientorder,current_storage.id,params[:assign_user])
    end
    render json: {}
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
