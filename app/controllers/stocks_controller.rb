class StocksController < ApplicationController
  load_and_authorize_resource

  # GET /stocks
  # GET /stocks.json
  def index
    @stocks_grid = initialize_grid(@stocks,
      :order => 'stocks.id',
      :order_direction => 'desc',
      include: [:shelf, :specification, :business, :supplier])
  end

  # GET /stocks/1
  # GET /stocks/1.json
  def show
  end

  # GET /stocks/new
  def new
  end

  # GET /stocks/1/edit
  def edit
  end

  # POST /stocks
  # POST /stocks.json
  def create
    respond_to do |format|
      if @stock.save
        @stock_log = StockLog.create(user: current_user, stock: @stock, operation: 'create_stock', status: 'checked', operation_type: 'in', amount: @stock.actual_amount, checked_at: Time.now)
        format.html { redirect_to @stock, notice: I18n.t('controller.create_success_notice', model: '库存') }
        format.json { render action: 'show', status: :created, location: @stock }
      else
        format.html { render action: 'new' }
        format.json { render json: @stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /stocks/1
  # PATCH/PUT /stocks/1.json
  def update
    respond_to do |format|
      # before_amount = @stock.actual_amount
      if @stock.update(stock_params)
        # if before_amount <= @stock.actual_amount
        #   operation_type = 'in'
        #   amount = @stock.actual_amount - before_amount
        # else
        #   operation_type = 'out'
        #   amount = before_amount - @stock.actual_amount
        # end
        @stock_log = StockLog.create(user: current_user, stock: @stock, operation: 'update_stock', status: 'checked', operation_type: 'reset', amount: @stock.actual_amount, checked_at: Time.now)

        format.html { redirect_to @stock, notice: I18n.t('controller.update_success_notice', model: '库存')}
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stocks/1
  # DELETE /stocks/1.json
  def destroy
    @stock.destroy
    @stock_log = StockLog.create(user: current_user, stock: @stock, operation: 'destroy_stock', status: 'checked', operation_type: 'out', amount: @stock.actual_amount, checked_at: Time.now)
    respond_to do |format|
      format.html { redirect_to stocks_url }
      format.json { head :no_content }
    end
  end

  def findstock

  end

  def warning_stocks_index
    @stocks = Stock.warning_stocks(current_storage)
    @relationships = []
    @stocks.each do |x|
      @relationships << Relationship.find_by(business_id: x.business_id, specification_id: x.specification_id, supplier_id: x.supplier_id)
    end
  end

  def getstock
    @stocks=[]
    if !params[:ex_code].empty?
      @relationship=Relationship.where("external_code=?",params[:ex_code]).accessible_by(current_ability).first
      if @relationship.nil?
        @stocks=[]
      else
        @stocks=Stock.where("business_id=? and specification_id=? and supplier_id=?",@relationship.business_id,@relationship.specification_id,@relationship.supplier_id)
      end

    elsif !params[:sixnine_code].empty?
      @specification=Specification.where("sixnine_code=?",params[:sixnine_code]).accessible_by(current_ability).first
      if @specification.nil?
          @stocks=[]
      else
          @stocks=Stock.where(specification_id: @specification)
      end
    else
      flash[:alert] = "输入69码或商品编码"
      redirect_to :action => 'findstock'
    end
    @allcnt={}
    @stocks.each do |s|
        product = [s.business_id,s.specification_id,s.supplier_id]
        warning_amount=Relationship.where("business_id=? and specification_id=? and supplier_id=?",s.business_id,s.specification_id,s.supplier_id).first.warning_amt
        if warning_amount.nil?
          warning_amount="hasnot"
        end

        if @allcnt.has_key?(product)
            @allcnt[product][0]=@allcnt[product][0]+s.actual_amount
            @allcnt[product][1]=@allcnt[product][1]+s.virtual_amount
        else
            @allcnt[product]=[s.actual_amount,s.virtual_amount,warning_amount]
        end
     end
   
    #binding.pry

  end

  def ready2bad
    @stock=Stock.find(params[:id])

  end

  def move2bad
    @stock=Stock.find(params[:stock_id])
    @shelf = Shelf.broken.where(shelf_code: params[:bad_shelf]).first
    amount = params[:bad_amount].to_i
    # binding.pry
    if amount > @stock.virtual_amount
        flash[:alert] = "输入的残次品数量大于库存预计数量"
        redirect_to :back
    else
        Stock.broken_stock_change(@stock, @shelf, amount, current_user)

        flash[:notice] = "移入残次品区成功"
        redirect_to :action => 'index'
    end 
  end

  def stock_stat_report

  end

  def stock_stat_report_down
    @business = Business.find(params[:stock][:business_id])
    year = params[:stock]["summ_date(1i)".to_sym].to_s
    month = params[:stock]["summ_date(2i)".to_sym].to_s
    op_type_in = []
    op_type_out = []
    if !params[:return_in].nil?
      op_type_in.push(params[:return_in])
    end

    if !params[:purchase_in].nil?
      op_type_in.push(params[:purchase_in])
    end

    if !params[:bad_in].nil?
      op_type_in.push(params[:return_in])
    end

    if !params[:bad_return].nil?
      op_type_in.push(params[:bad_return])
    end

    if !params[:b2c_out].nil?
      op_type_out.push(params[:b2c_out])
    end

    if !params[:b2b_out].nil?
      op_type_out.push(params[:b2b_out])
    end

    if !params[:move_bad].nil?
      op_type_out.push(params[:move_bad])
    end

    stock_hash = Stock.includes(:storage).where("storages.id = ?",current_storage.id).group(:business_id,:supplier_id,:specification_id).sum(:actual_amount)

    respond_to do |format|
        format.xls {   
          send_data(stock_qry_content_for(stock_hash,@business.id,year,month,op_type_in,op_type_out),  
            :type => "text/excel;charset=utf-8; header=present",  
            :filename => "#{year}年#{month}月库存状态表.xls")  
        }
    end
    # binding.pry
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    # def set_stock
    #   @stock = Stock.find(params[:id])
    # end

    # Never trust parameters from the scary internet, only allow the white list through.
    def stock_params
      params.require(:stock).permit(:shelf_id,:batch_no, :business_id, :supplier_id, :purchase_detail_id, :specification_id, :actual_amount, :virtual_amount,:desc)
    end

    def stock_qry_content_for(hashs,business_id,year,month,op_in_type,op_out_type)
      xls_report = StringIO.new  
      book = Spreadsheet::Workbook.new  
      sheet1 = book.create_worksheet :name => year+"年"+month+"月"

      blue = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 10  
      sheet1.row(0).default_format = blue  

      summ_start_dt = Date.new(Integer(year),Integer(month))
      summ_end_dt = summ_start_dt + 1.month - 1
      summ_last_month = (summ_start_dt-1.month).strftime("%Y%m")
      monthdays = Integer(summ_end_dt - summ_start_dt + 1)

      cnt_dt = []

      (summ_start_dt .. summ_end_dt).each do |date|
        cnt_dt.push(date.strftime("%Y%m%d"))
      end

      sheet1.row(0).concat %w{序号 产品编号 供应商名称 商品名称 上月结存数 实时库存 日均兑换量 月均兑换量 是否补货}
      sheet1.row(0).concat cnt_dt
      sheet1.row(0).concat %w{备用 合计数}
      sheet1.row(0).concat cnt_dt
      sheet1.row(0).concat %w{本月入库}
      sheet1[1,0]="合计"
      count_row = 2
      sp_no = 1
      col_num = 9
      row1_col_num = 9 
      out_hash_sum = 0
      in_hash_sum = 0

      sllos=StockLog.includes(:storage).where("storages.id=? and stock_logs.business_id = ? and stock_logs.operation in (?) and strftime('%Y%m',stock_logs.created_at)=?",current_storage.id,business_id,op_out_type,year.to_s+month.to_s).to_ary
      stock_out_all_summdt_hash = StockLog.where(id: sllos).group("strftime('%Y%m%d',created_at)").sum(:amount)
      
      (summ_start_dt .. summ_end_dt).each do |date|
          sheet1[1,row1_col_num]= stock_out_all_summdt_hash[date.strftime("%Y%m%d")].nil? ? 0 : stock_out_all_summdt_hash[date.strftime("%Y%m%d")]
          row1_col_num += 1
      end
      row1_col_num = row1_col_num + 2
      sllis=StockLog.includes(:storage).where("storages.id=? and stock_logs.business_id = ? and stock_logs.operation in (?) and strftime('%Y%m',stock_logs.created_at)=?",current_storage.id,business_id,op_in_type,year.to_s+month.to_s).to_ary
      stock_in_all_summdt_hash = StockLog.where(id: sllis).group("strftime('%Y%m%d',created_at)").sum(:amount)
      
      (summ_start_dt .. summ_end_dt).each do |date|
          sheet1[1,row1_col_num]= stock_in_all_summdt_hash[date.strftime("%Y%m%d")].nil? ? 0 : stock_in_all_summdt_hash[date.strftime("%Y%m%d")]
          row1_col_num += 1
      end


      hashs.each do |key,value| 
        sheet1[count_row,0]=sp_no.to_s
        sheet1[count_row,1]=Specification.find(key[2]).sku.to_s
        sheet1[count_row,2]=Supplier.find(key[1]).name.to_s
        sheet1[count_row,3]=Specification.find(key[2]).all_name.to_s
        sheet1[count_row,4]=StockMon.where("summ_date = ? and storage_id = ? and business_id = ? and supplier_id = ? and specification_id = ?",summ_last_month,current_storage.id,key[0],key[1],key[2]).blank? ? 0 : StockMon.where("summ_date = ? and storage_id = ? and business_id = ? and supplier_id = ? and specification_id = ?",summ_last_month,current_storage.id,key[0],key[1],key[2]).first.amount
        sheet1[count_row,5]=value

        slos=StockLog.includes(:storage).where("storages.id=? and stock_logs.business_id=? and stock_logs.supplier_id=? and stock_logs.specification_id=? and stock_logs.operation in (?) and strftime('%Y%m',stock_logs.created_at)=?",current_storage.id,key[0],key[1],key[2],op_out_type,year.to_s+month.to_s).to_ary
        stock_out_summdt_hash = StockLog.where(id: slos).group("strftime('%Y%m%d',created_at)").sum(:amount)
        if !stock_out_summdt_hash.nil?
          stock_out_summdt_hash.each do |key,value|
            out_hash_sum += value
          end
        end

        (summ_start_dt .. summ_end_dt).each do |date|
          sheet1[count_row,col_num]= stock_out_summdt_hash[date.strftime("%Y%m%d")].nil? ? 0 : stock_out_summdt_hash[date.strftime("%Y%m%d")]
          col_num += 1
        end

        col_num = col_num + 1
        sheet1[count_row,6]=out_hash_sum/monthdays
        sheet1[count_row,7]=out_hash_sum
        sheet1[count_row,col_num]=out_hash_sum
        col_num = col_num + 1

        slis=StockLog.includes(:storage).where("storages.id=? and stock_logs.business_id=? and stock_logs.supplier_id=? and stock_logs.specification_id=? and stock_logs.operation in (?) and strftime('%Y%m',stock_logs.created_at)=?",current_storage.id,key[0],key[1],key[2],op_in_type,year.to_s+month.to_s).to_ary
        stock_in_summdt_hash = StockLog.where(id: slis).group("strftime('%Y%m%d',created_at)").sum(:amount)
        if !stock_in_summdt_hash.nil?
          stock_in_summdt_hash.each do |key,value|
            in_hash_sum += value
          end
        end

        (summ_start_dt .. summ_end_dt).each do |date|
          sheet1[count_row,col_num]= stock_in_summdt_hash[date.strftime("%Y%m%d")].nil? ? 0 : stock_in_summdt_hash[date.strftime("%Y%m%d")]
          col_num += 1
        end
        sheet1[count_row,col_num]=in_hash_sum

        count_row += 1
        sp_no += 1
        col_num = 9 
        out_hash_sum = 0
        in_hash_sum = 0
      end

      book.write xls_report  
      xls_report.string  
    end

end
