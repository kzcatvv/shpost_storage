class PurchasesController < ApplicationController
  load_and_authorize_resource

  user_logs_filter only: [:create, :close, :destroy], symbol: :name#, object: :user, operation: '新增用户'
  user_logs_filter only: [:check], symbol: :no, operation: '采购单确认入库'#, object: :user, operation: '新增用户'
  user_logs_filter only: [:onecheck], symbol: :desc, operation: '采购单明细确认入库', object: :stock_log
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

    @stock_logs_grid = initialize_grid(@purchase.stock_logs)
  end

  def check
    @stock_logs = @purchase.stock_logs
    @stock_logs_grid = initialize_grid(@stock_logs)
    respond_to do |format|
      if @purchase.check!
        format.html { render action: 'stock_in' }
        format.json { head :no_content }
      else
        format.html { render action: 'stock_in', javascript: "alert('123')" }
        format.json { head :no_content }
      end
    end
  end

  def onecheck
    @stock_logs = @purchase.stock_logs
    @stock_logs_grid = initialize_grid(@stock_logs)

    StockLog.find(params[:stock_log]).check!
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
                business = Business.accessible_by(current_ability).find_by name: instance.cell(line,'B').to_s

                purchase = Purchase.create! unit_id: unit.id, business_id: business.id, desc: instance.cell(line,'C').to_s, status: status, storage_id: storage.id, name: instance.cell(line,'A').to_s
              end
              supplier=Supplier.accessible_by(current_ability).find_by name:instance.cell(line,'E').to_s

              specifications=Specification.accessible_by(current_ability).where(sixnine_code:instance.cell(line,'G').to_s)
              specification=nil
              if specifications.size > 1
                specification=specifications.find_by name: instance.cell(line,'F').to_s
              elsif specifications.size == 1
                specification = specifications.first
              end

           #   purchase_detail = PurchaseDetail.create! name:instance.cell(line,'A'),purchase_id: purchase.id,supplier_id: supplier.id,specification_id: specification.id,qg_period:instance.cell(line,'E'),amount:instance.cell(line,'F').to_i,desc:instance.cell(line,'G'),sum:instance.cell(line,'F').to_f, status:"waiting"
            purchase_detail = PurchaseDetail.create! name:instance.cell(line,'D'),purchase_id: purchase.id,supplier_id:supplier.id,specification_id: specification.id,expiration_date:instance.cell(line,'H'),amount:instance.cell(line,'I').to_i,desc:instance.cell(line,'J'), status:"waiting"

             # batch_no= purchase_detail.set_batch_no
             # puts 
             #  purchase_detail.update_attribute(:batch_no,batch_no)
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
    text.to_s.split('.0')[0]
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
