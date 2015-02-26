class PurchasesController < ApplicationController
  load_and_authorize_resource

  user_logs_filter only: [:create, :close, :destroy], symbol: :name, parent: :purchase#, object: :user, operation: '新增用户'
  user_logs_filter only: [:check], symbol: :no, operation: '采购单确认入库', parent: :purchase#, object: :user, operation: '新增用户'
  user_logs_filter only: [:onecheck], symbol: :desc, operation: '采购单明细确认入库', object: :stock_log, parent: :purchase
  # GET /purchasees
  # GET /purchasees.json
  def index
    @purchases_grid = initialize_grid(@purchases)
  end

  # GET /purchasees/1
  # GET /purchasees/1.json
  def show
  end

  # GET /purchasees/new
  def new
   # @purchase = Purchase.new
    
  end

  # GET /purchasees/1/edit
  def edit
  end

  # POST /purchasees
  # POST /purchasees.json
  def create
   # @purchase = Purchatimese.new(purchase_params)
    @purchase.unit = current_user.unit
    @purchase.status = Purchase::STATUS[:opened]
    @purchase.storage = current_storage

    respond_to do |format|
      if @purchase.save
        format.html { redirect_to @purchase, notice: I18n.t('controller.create_success_notice', model: '采购单') }
        format.json { render action: 'show', status: :created, location: @purchase }
      else
        format.html { render action: 'new' }
        format.json { render json: @purchase.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /purchasees/1
  # PATCH/PUT /purchasees/1.json
  def update
    respond_to do |format|
      if @purchase.update(purchase_params)
        format.html { redirect_to @purchase, notice: I18n.t('controller.update_success_notice', model: '采购单')  }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @purchase.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /purchasees/1
  # DELETE /purchasees/1.json
  def destroy
    @purchase.destroy
    respond_to do |format|
      format.html { redirect_to purchases_url }
      format.json { head :no_content }
    end
  end

  # PATCH /specifications/1
  def stock_in
    #@stock_logs = []
      
    Stock.purchase_stock_in(@purchase, current_user)

    @stock_logs = @purchase.stock_logs

    @stock_logs_grid = initialize_grid(@purchase.stock_logs)
  end

  def assign
    @tasker = Task.tasker_in_work(@purchase)
    @task_finished = !@purchase.has_waiting_stock_logs()
    @sorters = current_storage.get_sorter()
  end

  def assign_select
    if @purchase.has_waiting_stock_logs()
      Task.save_task(@purchase,current_storage.id,params[:assign_user])
    end
    render json: {}
  end

  def check
    @stock_logs = @purchase.stock_logs
    @stock_logs_grid = initialize_grid(@stock_logs)
    respond_to do |format|
      if @purchase.check!
        format.html { render action: 'stock_in' }
        format.json { head :no_content }
      else
        format.html { render action: 'stock_in' }
        format.json { head :no_content }
      end
    end
  end

  def onecheck
    @stock_logs = @purchase.stock_logs
    @stock_logs_grid = initialize_grid(@stock_logs)

    @stock_log = StockLog.find(params[:stock_log])
    @stock_log.check!
    render action: 'stock_in'
  end


  def close
    respond_to do |format|
      if @purchase.close
        format.html { redirect_to purchases_url }
        format.json { head :no_content }
      else
        format.html { redirect_to purchases_url, javascript: "alert('123')" }
        format.json { head :no_content }
      end
    end
  end


 def purchase_import
    unless request.get?
      if file = upload_purchase(params[:file]['file'])
        Purchase.transaction do
          begin
            instance=nil
            if file.include?('.xlsx')
              instance= Roo::Excelx.new(file)
            elsif file.include?('.xls')
              instance= Roo::Excel.new(file)
            elsif file.include?('.csv')
              instance= Roo::CSV.new(file)
            end
            instance.default_sheet = instance.sheets.first

            purchase = nil
            2.upto(instance.last_row) do |line|
               #binding.pry

              if !instance.cell(line,'A').to_s.blank?
                unit = current_user.unit
                status = Purchase::STATUS[:opened]
                storage = current_storage
                business = Business.accessible_by(current_ability).find_by name: to_string(instance.cell(line,'B'))

                if business.blank?
                  raise "导入文件第" + line.to_s + "行数据, 找不到商户，导入失败"
                end
                purchase = Purchase.accessible_by(current_ability).find_by name: to_string(instance.cell(line,'A'))
                if purchase.blank?
                  purchase = Purchase.create! unit_id: unit.id, business_id: business.id, desc: to_string(instance.cell(line,'C')), status: status, storage_id: storage.id, name: to_string(instance.cell(line,'A'))
                else
                  if purchase.status.eql? Purchase::STATUS[:opened]
                    purchase.update(business_id: business.id, desc: to_string(instance.cell(line,'C')))
                  else
                    raise "导入文件第" + line.to_s + "行数据, 同名采购单已关闭，导入失败"
                  end
                end
              end
              supplier=Supplier.accessible_by(current_ability).find_by name: to_string(instance.cell(line,'E'))

              if supplier.blank?
                raise "导入文件第" + line.to_s + "行数据, 找不到供应商，导入失败"
              end

              specifications=Specification.accessible_by(current_ability).where(sixnine_code: to_string(instance.cell(line,'G')))

              specification=nil

              if specifications.size > 1
                specification=specifications.find_by name: to_string(instance.cell(line,'F'))
              elsif specifications.size == 1
                specification = specifications.first
              end

              if specification.blank?
                raise "导入文件第" + line.to_s + "行数据, 找不到69码或规格名称，导入失败"
              end

              expiration_date = to_string(instance.cell(line, 'H'))
              purchase_detail = purchase.purchase_details.find_by(supplier_id: supplier.id, specification_id: specification.id)
              if purchase_detail.blank?
                purchase_detail = PurchaseDetail.create! name: to_string(instance.cell(line, 'D')), purchase_id: purchase.id, supplier_id: supplier.id, specification_id: specification.id, expiration_date: expiration_date.blank? ? nil : expiration_date.to_datetime.strftime("%Y-%m-%d %H:%M:%S"), amount: instance.cell(line,'I').to_i, desc: to_string(instance.cell(line,'J')), status: "waiting"
              else
                # if purchase_detail.status.eql? PurchaseDetail::STATUS[:waiting]
                  purchase_detail.update(name: to_string(instance.cell(line, 'D')), expiration_date: expiration_date.blank? ? nil : expiration_date.to_datetime.strftime("%Y-%m-%d %H:%M:%S"), amount: instance.cell(line,'I').to_i, desc: to_string(instance.cell(line,'J')))
                # else
                #   raise "导入文件第" + line.to_s + "行数据, 同商品规格采购明细已处理，导入失败"
                # end
              end
              arrival_start = 11
              arrival_length = 3
              while true
                arrival_amount = instance.cell(line,arrival_start)
                arrival_expiration = to_string(instance.cell(line,arrival_start+1))
                arrival_at = to_string(instance.cell(line,arrival_start+2))

                if arrival_amount.blank? && arrival_expiration.blank? && arrival_at.blank?
                  break
                end
                if !arrival_amount.is_a? Float
                  raise "导入文件第" + line.to_s + "行数据, 到货数量非数字，导入失败"
                end

                if arrival_at.blank?
                  raise "导入文件第" + line.to_s + "行数据, 缺少到达日期，导入失败"
                end

                purchase_arrival = purchase_detail.purchase_arrivals.find_by(arrived_at: arrival_at.blank? ? nil : arrival_at.to_datetime.strftime("%Y-%m-%d %H:%M:%S"))
                if purchase_arrival.blank?
                  PurchaseArrival.create! arrived_amount: arrival_amount, expiration_date: arrival_expiration.blank? ? nil : arrival_expiration.to_datetime.strftime("%Y-%m-%d %H:%M:%S"), arrived_at: arrival_at.blank? ? nil : arrival_at.to_datetime.strftime("%Y-%m-%d %H:%M:%S"), purchase_detail_id: purchase_detail.id, status: 'waiting'
                else
                  if purchase_arrival.status.eql? 'waiting'
                    purchase_arrival.update(arrived_amount: arrival_amount, expiration_date: arrival_expiration.blank? ? nil : arrival_expiration.to_datetime.strftime("%Y-%m-%d %H:%M:%S"))
                  else
                    raise "导入文件第" + line.to_s + "行数据, " + arrival_at + "到达明细已处理，导入失败"
                  end
                end
                arrival_start = arrival_start + arrival_length
              end
            end
            flash[:alert] = "导入成功"
          rescue Exception => e
            flash[:alert] = e.to_s
            raise ActiveRecord::Rollback
          end
        end
      end   
    end
  end

  def scan
    @scan = @purchase
    @scans = @purchase.purchase_details
    # render  'scans/scans'
    render 'scans/scans'
  end

  def scan_check
    @purchase.purchase_details.each do |scan|
        scan.amount = params["realam_#{scan.id}".to_sym]
        scan.save
    end
    redirect_to action: :index
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_purchase
      @purchase = Purchase.find(params[:id])
    end


  def to_string(text)
    if text.is_a? Float
      return text.to_s.split('.0')[0]
    else
      return text
    end
  end

    # Use callbacks to share common setup or constraints between actions.
    # def set_commodity
    #   @commodity = Commodity.find(params[:id])
    # end

    # Never trust parameters from the scary internet, only allow the white list through.
    


  def upload_purchase(file)
    if !file.original_filename.empty?
      puts 99999
      direct = "#{Rails.root}/upload/goods/"
      filename = "#{Time.now.to_f}_#{file.original_filename}"
      file_path = direct + filename
      puts file_path
      File.open(file_path, "wb") do |f|
        f.write(file.read)
      end
      file_path
    end
  end



    # Never trust parameters from the scary internet, only allow the white list through.
    def purchase_params
      params.require(:purchase).permit(:no, :name, :business_id, :amount, :sum, :desc)
    end
end
