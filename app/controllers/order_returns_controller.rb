class OrderReturnsController < ApplicationController
  load_and_authorize_resource

  user_logs_filter only: [:return_check], symbol: :desc, operation: '退件入库确认', object: :stock_log
  #before_action :set_order_return, only: [:show, :edit, :update, :destroy]

  # GET /order_returns
  # GET /order_returns.json
  def index

  end

  # GET /order_returns/1
  # GET /order_returns/1.json
  def show
  end

  # GET /order_returns/new
  def new

  end

  # GET /order_returns/1/edit
  def edit
  end

  # POST /order_returns
  # POST /order_returns.json
  def create

    respond_to do |format|
      if @order_return.save
        format.html { redirect_to @order_return, notice: 'OrderReturn was successfully created.' }
        format.json { render action: 'show', status: :created, location: @order_return }
      else
        format.html { render action: 'new' }
        format.json { render json: @order_return.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /order_returns/1
  # PATCH/PUT /order_returns/1.json
  def update
    respond_to do |format|
      if @order_return.update(order_return_params)
        format.html { redirect_to @order_return, notice: 'OrderReturn was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @order_return.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /order_returns/1
  # DELETE /order_returns/1.json
  def destroy
    respond_to do |format|
      format.html { redirect_to order_returns_url }
      format.json { head :no_content }
    end
  end

  def pack_return
    @order_details = []
  end

  def find_tracking_number
    @order = Order.where(tracking_number: params[:tracking_number]).accessible_by(current_ability).first
    ods=@order.order_details
    ords = OrderReturnDetail.where(order_detail_id: ods)
    rt_id_hash=[]
    ords.each do |ord|
      rt_id_hash.push(ord.order_detail_id)
    end
    if ords.blank?
      if @order.nil?
        @curr_order=0
        @order_details=[]
      else
        @curr_order=@order.id
        @order_details = @order.order_details
      end
    else
      if ods.count <= ords.count
        @curr_order = -1
        @order_details=[]
      else
        @curr_order=@order.id
        @order_details = @order.order_details.where("id not in (?)",rt_id_hash)
      end
    end
    respond_to do |format|
          format.js 
    end

  end

  def do_return
    sklogs=[]
    time = Time.now
    # binding.pry
    # @batch_no = time.year.to_s + time.month.to_s.rjust(2,'0') + time.day.to_s.rjust(2,'0') + (OrderReturn.select(:batch_no).distinct.count+1).to_s.rjust(5,'0')
    @order_return = OrderReturn.create(unit_id:current_user.unit_id,storage_id:current_storage.id,status:"waiting")
    @batchid =@order_return.batch_no
    params[:cbids].each do |id|
      reason = params[("rereason_"+id).to_sym]
      is_bad = params[("st_"+id).to_sym]

      @order_return.order_return_details.create(order_detail_id: id, return_reason: reason, is_bad: (is_bad.eql? '否') ? 'no' : 'yes', status: 'waiting')
    end
    
    Stock.order_return_stock_in(@order_return, current_user)

    @stock_logs = @order_return.stock_logs

    @stock_logs_grid = initialize_grid(@stock_logs)
  end

  def return_check

      @order_return=OrderReturn.where("batch_no=?",params[:format]).first

      @order_return.check!
      

      redirect_to :action => 'pack_return'

  end

  def export_order_returns()
    @order_returns = OrderReturn.all
    if @order_returns.nil?
       flash[:alert] = "无退件信息"
       redirect_to :action => 'pack_return'
    else
      respond_to do |format|
        format.xls {   
          send_data(exportorder_returns_xls_content_for(@order_returns),  
                :type => "text/excel;charset=utf-8; header=present",  
                :filename => "OrderReturns_#{Time.now.strftime("%Y%m%d")}.xls")  
        }  
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order_return
      @order_return = OrderReturn.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_return_params
      params.require(:order_return).permit(:order_detail_id, :return_reason, :is_bad)
    end

    def exportorder_returns_xls_content_for(objs)  
      xls_report = StringIO.new
      book = Spreadsheet::Workbook.new  
      sheet1 = book.create_worksheet :name => "OrderReturns"  

      blue = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 10  
      sheet1.row(0).default_format = blue  

      sheet1.row(0).concat %w{退件ID 退件时间 退件理由 是否破损 退件面单号 批次号 状态}  
      count_row = 1
      objs.each do |obj|  
        sheet1[count_row,0]=obj.id
        sheet1[count_row,1]=obj.created_at
        sheet1[count_row,2]=obj.return_reason
        sheet1[count_row,3]=obj.is_bad
        sheet1[count_row,4]=obj.order_detail.order.tracking_number
        sheet1[count_row,5]=obj.batch_no
        sheet1[count_row,6]=obj.status
        count_row += 1
      end  
  
      book.write xls_report  
      xls_report.string  
    end
end
