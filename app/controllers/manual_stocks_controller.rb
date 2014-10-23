class ManualStocksController < ApplicationController
  load_and_authorize_resource
  # before_action :set_manual_stock, only: [:show, :edit, :update, :destroy]

  # GET /manual_stocks
  # GET /manual_stocks.json
  def index
    # @manual_stocks = ManualStock.all.order(created_at: :desc)
    @manual_stocks_grid = initialize_grid(@manual_stocks, order: 'created_at',order_direction: :desc )
  end

  # GET /manual_stocks/1
  # GET /manual_stocks/1.json
  def show
  end

  # GET /manual_stocks/new
  def new
    # @manual_stock = ManualStock.new
  end

  # GET /manual_stocks/1/edit
  def edit
  end

  # POST /manual_stocks
  # POST /manual_stocks.json
  def create
    time=Time.new
    @manual_stock.unit = current_user.unit
    @manual_stock.status = ManualStock::STATUS[:opened]
    @manual_stock.storage = current_storage
    @manual_stock.no=time.year.to_s+time.month.to_s.rjust(2,'0')+time.day.to_s.rjust(2,'0')+ManualStock.count.to_s.rjust(5,'0')

    respond_to do |format|
      if @manual_stock.save
        format.html { redirect_to @manual_stock, notice: 'Manual stock was successfully created.' }
        format.json { render action: 'show', status: :created, location: @manual_stock }
      else
        format.html { render action: 'new' }
        format.json { render json: @manual_stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /manual_stocks/1
  # PATCH/PUT /manual_stocks/1.json
  def update
    respond_to do |format|
      if @manual_stock.update(manual_stock_params)
        format.html { redirect_to @manual_stock, notice: 'Manual stock was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @manual_stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /manual_stocks/1
  # DELETE /manual_stocks/1.json
  def destroy
    @manual_stock.destroy
    respond_to do |format|
      format.html { redirect_to manual_stocks_url }
      format.json { head :no_content }
    end
  end

  def stock_out
    product_hash = {}
    sklogs=[]

    manual_stock=ManualStock.find(params[:id])

      if Stock.check_out_stocks(manual_stock, manual_stock.manual_stock_details, current_storage)
        manual_stock.manual_stock_details.each do |detail|
          product_hash = Stock.get_product_hash(manual_stock,detail,product_hash)
          # product = [order.business,orderdtl.specification,orderdtl.supplier]
          # if allcnt.has_key?(product)
          #     allcnt[product][0]=allcnt[product][0]+orderdtl.amount
          #     allcnt[product][1]<<orderdtl
          # else
          #     allcnt[product]=[orderdtl.amount, [orderdtl]]
          # end
        end
      else
        order.update_attribute(:is_shortage,"yes")
      end

    # puts allcnt

    sklogs = Stock.stock_out(product_hash, current_storage, current_user)

    @stock_logs = StockLog.where(id: sklogs)
    #binding.pry
    @stock_logs_grid = initialize_grid(@stock_logs)

  end

  def check
    @stock_logs = @manual_stock.stock_logs
    @stock_logs_grid = initialize_grid(@stock_logs)
    respond_to do |format|
      if @manual_stock.check
        format.html { render action: 'stock_out' }
        format.json { head :no_content }
      else
        format.html { render action: 'stock_out' }
        format.json { head :no_content }
      end
    end
  end

  def onecheck
    @stock_logs = @manual_stock.stock_logs
    @stock_logs_grid = initialize_grid(@stock_logs)

    StockLog.find(params[:stock_log]).check
    render action: 'stock_out'
  end


  def close
    respond_to do |format|
      if @manual_stock.close
        format.html { redirect_to manual_stocks_url }
        format.json { head :no_content }
      else
        format.html { redirect_to pmanual_stocks_url, javascript: "alert('123')" }
        format.json { head :no_content }
      end
    end
  end


 def manual_stock_import
    unless request.get?
      if file = upload_manual_stock(params[:file]['file'])
        ManualStock.transaction do
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

            manual_stock = nil
            2.upto(instance.last_row) do |line|
               #binding.pry

              if !instance.cell(line,'A').to_s.blank?
                unit = current_user.unit
                status = ManualStock::STATUS[:opened]
                storage = current_storage
                business = Business.find_by name: instance.cell(line,'B').to_s
                time=Time.new
                no=time.year.to_s+time.month.to_s.rjust(2,'0')+time.day.to_s.rjust(2,'0')+Purchase.count.to_s.rjust(5,'0')

                manual_stock = ManualStock.create! no: no, unit_id: unit.id, business_id: business.id, desc: instance.cell(line,'C').to_s, status: status, storage_id: storage.id, name: instance.cell(line,'A').to_s
              end
              supplier=Supplier.find_by name:instance.cell(line,'E').to_s

              specifications=Specification.where(sixnine_code:instance.cell(line,'G').to_s)
              specification=nil
              if specifications.size > 1
                specification=specifications.find_by name: instance.cell(line,'F').to_s
              elsif specifications.size == 1
                specification = specifications.first
              end
              # todo:define the manual stock import file
              manual_stock_detail = ManualStockDetail.create! name:instance.cell(line,'D'),manual_stock_id: manual_stock.id,supplier_id:supplier.id,specification_id: specification.id,amount:instance.cell(line,'I').to_i,desc:instance.cell(line,'J'), status:"waiting"
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


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_manual_stock
      @manual_stock = ManualStock.find(params[:id])
    end

    def upload_manual_stock(file)
      if !file.original_filename.empty?
        direct = "#{Rails.root}/upload/manual_stock/"
        filename = "#{Time.now.to_f}_#{file.original_filename}"
        file_path = direct + filename
        Rails.logger.info file_path
        File.open(file_path, "wb") do |f|
          f.write(file.read)
        end
        file_path
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def manual_stock_params
      params.require(:manual_stock).permit(:no, :name, :desc, :status, :unit_id, :business_id, :storage_id)
    end
end
