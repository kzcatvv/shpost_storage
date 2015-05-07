class StocksController < ApplicationController
  load_and_authorize_resource

  # GET /stocks
  # GET /stocks.json
  def index
    @stocks_grid = initialize_grid(@stocks,
      :order => 'stocks.id',
      :order_direction => 'desc',
      include: [:shelf, :specification, :business, :supplier],
      :name => 'stocks',
      :enable_export_to_csv => true,
      :csv_file_name => 'stocks')
    
    export_grid_if_requested
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
    # @relationships = []
    # @stocks.each do |x|
    #   @relationships << Relationship.find_by(business_id: x.business_id, specification_id: x.specification_id, supplier_id: x.supplier_id)
    # end
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
        Stock.move_stock_change(@stock, @shelf, amount, current_user, true)

        flash[:notice] = "移入残次品区成功"
        redirect_to :action => 'index'
    end 
  end

  def find_stock_in_shelf
      # binding.pry
      @stocks = Stock.where(shelf_id: params[:shelf_id]).accessible_by(current_ability).map{|u| ["#{u.specification.name} #{u.batch_no}",u.id]}.insert(0,"请选择")
      @rowid = "md_stock_"+params[:row_id]
      
      respond_to do |format|
        format.js 
      end
  end

  def find_stock_amount
    @actual_amount = Stock.find(params[:stock_id]).actual_amount
    @rowid = "md_stock_amount_"+params[:row_id].to_s
    respond_to do |format|
        format.js 
    end
  end

  # GET /stocks
  # GET /stocks.json
  def querystock
    @actual_hash = {}
    @virtual_hash = {}
    @stocks=Stock.all
    @selrels=[]
    @zerorels=""
    @ex_code=params[:ex_code]
    @sixnine_code=params[:sixnine_code]
    @area_code=params[:area_code]
    @is_zero=params[:is_zero]
    zerostocks=[]

    if !params[:ex_code].blank?
      @stocks=@stocks.includes(:relationship).where("relationships.external_code=?",params[:ex_code]).accessible_by(current_ability)
      @selrels = Relationship.where("external_code=?",params[:ex_code]).accessible_by(current_ability).first
    end
    if !params[:sixnine_code].blank?
      @stocks=@stocks.includes(:specification).where("specifications.sixnine_code=?",params[:sixnine_code]).accessible_by(current_ability)

      @specification=Specification.accessible_by(current_ability).where("sixnine_code=?",params[:sixnine_code]).first
      if !@specification.blank?
        if @selrels.blank?
          @selrels = Relationship.where(specification: @specification)
        else
          @selrels = @selrels.where(specification: @specification)
        end
      end
    end

    if !params[:area_code].blank?
      # @area=Area.where("area_code=?",params[:area_code]).accessible_by(current_ability).first
      # if !@area.blank?
      #   if !@area.shelves.blank?
      #     if @stocks.blank?
      #       @stocks=Stock.where("stocks.shelf_id in (?)",@area.shelves.ids)
      #     else 
      #       @stocks=@stocks.where("stocks.shelf_id in (?)",@area.shelves.ids)
      #     end
      #   end 
      # end
      @stocks=@stocks.includes(:area).accessible_by(current_ability).where("areas.area_code=?",params[:area_code])
    end

    # if @stocks.blank?
    #   @actual_hash = Stock.includes(:area).where("areas.storage_id = ?",current_storage.id).group("areas.id").group("stocks.business_id").group("stocks.supplier_id").group("stocks.specification_id").order("areas.id,stocks.business_id,stocks.supplier_id,stocks.specification_id").sum(:actual_amount)

    #   vstocks = Stock.includes(:area).where("areas.storage_id = ?",current_storage.id).order("areas.id,stocks.business_id,stocks.supplier_id,stocks.specification_id")
    #   vstocks.each do |s|
    #     gb = [s.shelf.area.id,s.business_id,s.supplier_id,s.specification_id]
    #     if @virtual_hash.has_key?(gb)
    #       @virtual_hash[gb]=@virtual_hash[gb]+s.virtual_amount
    #     else
    #       @virtual_hash[gb]=s.virtual_amount
    #     end
    #   end
    #   if params[:is_zero] == 'yes'
    #     st = Stock.includes(:area).where("areas.storage_id = ?",current_storage.id).to_ary
    #     slre = Stock.where(id: st).select(:relationship_id).distinct
    #     slreary = Relationship.where(id: slre).to_ary
    #     zerostocks = Relationship.where(id: slreary)
    #     if @selrel.blank?
    #       @zerorels = Relationship.where.not(id: zerostocks)
    #     else
    #       @zerorels = @selrels.where.not(id: zerostocks)
    #     end
    #   end
    # else
      @actual_hash = @stocks.includes(:area).where("areas.storage_id = ?",current_storage.id).group("areas.id").group("stocks.business_id").group("stocks.supplier_id").group("stocks.specification_id").order("areas.id,stocks.business_id,stocks.supplier_id,stocks.specification_id").sum(:actual_amount)
      vstocks = @stocks.includes(:area).where("areas.storage_id = ?",current_storage.id).order("areas.id,stocks.business_id,stocks.supplier_id,stocks.specification_id")
      vstocks.each do |s|
        gb = [s.shelf.area.id,s.business_id,s.supplier_id,s.specification_id]
        if @virtual_hash.has_key?(gb)
          @virtual_hash[gb]=@virtual_hash[gb]+s.virtual_amount
        else
          @virtual_hash[gb]=s.virtual_amount
        end
      end

      if params[:is_zero] == 'yes'
        zerostockstemp = @stocks.select(:relationship_id).distinct
        zerostockstemp.each do |s|
          zerostocks << s.relationship_id
        end

        if @selrel.blank?
          resls = Relationship.where(id: zerostocks)
          @zerorels = Relationship.where.not(id: resls)
        else
          resls = Relationship.where(id: zerostocks)
          @zerorels = @selrels.where.not(id: resls)
        end
      end
      
    # end
  end

  def export()
    @actual_hash = {}
    @virtual_hash = {}
    @stocks=Stock.all
    @selrels=[]
    @zerorels=""
    zerostocks=[]

    if !params[:ex_code].blank?
      @stocks=@stocks.includes(:relationship).where("relationships.external_code=?",params[:ex_code]).accessible_by(current_ability)
      @selrels = Relationship.where("external_code=?",params[:ex_code]).accessible_by(current_ability).first
    end
    if !params[:sixnine_code].blank?
      @stocks=@stocks.includes(:specification).where("specifications.sixnine_code=?",params[:sixnine_code]).accessible_by(current_ability)
      @specification=Specification.accessible_by(current_ability).where("sixnine_code=?",params[:sixnine_code]).first
      if !@specification.blank?
        if @selrels.blank?
          @selrels = Relationship.where(specification: @specification)
        else
          @selrels = @selrels.where(specification: @specification)
        end
      end
    end
    if !params[:area_code].blank?
      # @area=Area.accessible_by(current_ability).where("area_code=?",params[:area_code]).first
      # if !@area.blank?
      #   if !@area.shelves.blank?
      #     if @stocks.blank?
      #       @stocks=Stock.where("stocks.shelf_id in (?)",@area.shelves.ids)
      #     else 
      #       @stocks=@stocks.where("stocks.shelf_id in (?)",@area.shelves.ids)
      #     end
      #   end
      # end
      @stocks=@stocks.includes(:area).accessible_by(current_ability).where("areas.area_code=?",params[:area_code])
      
    end

    # if @stocks.blank?
    #   @actual_hash = Stock.includes(:area).where("areas.storage_id = ?",current_storage.id).group("areas.id").group("stocks.business_id").group("stocks.supplier_id").group("stocks.specification_id").order("areas.id,stocks.business_id,stocks.supplier_id,stocks.specification_id").sum(:actual_amount)
    #   vstocks = Stock.includes(:area).where("areas.storage_id = ?",current_storage.id).order("areas.id,stocks.business_id,stocks.supplier_id,stocks.specification_id")
    #   vstocks.each do |s|
    #     gb = [s.shelf.area.id,s.business_id,s.supplier_id,s.specification_id]
    #     if @virtual_hash.has_key?(gb)
    #       @virtual_hash[gb]=@virtual_hash[gb]+s.virtual_amount
    #     else
    #       @virtual_hash[gb]=s.virtual_amount
    #     end
    #   end

    #   if params[:is_zero] == 'yes'
    #     st = Stock.includes(:area).where("areas.storage_id = ?",current_storage.id).to_ary
    #     slre = Stock.where(id: st).select(:relationship_id).distinct
    #     slreary = Relationship.where(id: slre).to_ary
    #     zerostocks = Relationship.where(id: slreary)
    #     if @selrel.blank?
    #       @zerorels = Relationship.where.not(id: zerostocks)
    #     else
    #       @zerorels = @selrels.where.not(id: zerostocks)
    #     end
    #   end

    # else
      @actual_hash = @stocks.includes(:area).where("areas.storage_id = ?",current_storage.id).group("areas.id").group("stocks.business_id").group("stocks.supplier_id").group("stocks.specification_id").order("areas.id,stocks.business_id,stocks.supplier_id,stocks.specification_id").sum(:actual_amount)
      vstocks = @stocks.includes(:area).where("areas.storage_id = ?",current_storage.id).order("areas.id,stocks.business_id,stocks.supplier_id,stocks.specification_id")
      vstocks.each do |s|
        gb = [s.shelf.area.id,s.business_id,s.supplier_id,s.specification_id]
        if @virtual_hash.has_key?(gb)
          @virtual_hash[gb]=@virtual_hash[gb]+s.virtual_amount
        else
          @virtual_hash[gb]=s.virtual_amount
        end
      end

      if params[:is_zero] == 'yes'
        zerostockstemp = @stocks.select(:relationship_id).distinct
        zerostockstemp.each do |s|
          zerostocks << s.relationship_id
        end
        if @selrel.blank?
          resls = Relationship.where(id: zerostocks)
          @zerorels = Relationship.where.not(id: resls)
        else
          resls = Relationship.where(id: zerostocks)
          @zerorels = @selrels.where.not(id: resls)
        end
      end

    # end

    # respond_to do |format|
    #   format.xls {   
        send_data(exportstocks_xls_content_for(@actual_hash,@virtual_hash,@zerorels), :type => "text/excel;charset=utf-8; header=present", :filename => "Stocks_#{Time.now.strftime("%Y%m%d")}.xls")  
    #   }  
    # end
    
  end


  def exportstocks_xls_content_for(actual_hash,virtual_hash,zerorels)  
    
    xls_report = StringIO.new  
    book = Spreadsheet::Workbook.new  
    sheet1 = book.create_worksheet :name => "Stocks"  

    blue = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 10  
    sheet1.row(0).default_format = blue  

    sheet1.row(0).concat %w{区域 商品规格 实际库存 预计库存}  
    count_row = 1

    actual_hash.each do |key,value| 
      if !key[0].blank?
        area = Area.find_by id:key[0]
      end
      sheet1[count_row,0] = area.blank?? "":area.name
      if !key[3].blank?
        specification = Specification.find_by id:key[3]
      end
      sheet1[count_row,1] = specification.blank?? "":specification.full_title
      sheet1[count_row,2] = actual_hash[key]
      sheet1[count_row,3] = virtual_hash[key]

    count_row += 1
    end

    if !zerorels.blank?
      zerorels.each do |rel|
        sheet1[count_row,0] = ""
        sheet1[count_row,1] = rel.specification.blank? ? "" : rel.specification.full_title
        sheet1[count_row,2] = 0
        sheet1[count_row,3] = 0
        count_row += 1
      end
    end

    book.write xls_report  
      xls_report.string  
  end
  
  def stock_details
    key0=params[:key0]
    key1=params[:key1]
    key2=params[:key2]
    key3=params[:key3]
    
    @area = Area.where("areas.storage_id = ? and areas.id = ?",current_storage.id,key0).accessible_by(current_ability).first
    @stocks = Stock.where("stocks.business_id=? and stocks.supplier_id=? and stocks.specification_id=? and stocks.shelf_id in (?)",key1,key2,key3,@area.shelves.ids)

    @stock_details_grid = initialize_grid(@stocks,
      :order => 'stocks.id',
      :order_direction => 'desc',
      include: [:shelf, :specification, :business, :supplier])
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

    

end
