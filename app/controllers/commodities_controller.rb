class CommoditiesController < ApplicationController
  load_and_authorize_resource

  @@comm_export = []
  # GET /commodities
  # GET /commodities.json
  def index
    if !params[:code].blank?
      specifications = Specification.accessible_by(current_ability).where(["sixnine_code = ? or sku = ?", params[:code], params[:code]])
      cid = []
      specifications.each do |s|
        cid << s.commodity.id
      end
      @commodities = Commodity.where(id: cid)
    end
    @commodities = initialize_grid(@commodities,
                   :order => 'commodities.id',
                   :order_direction => 'desc')
    @commodities.with_resultset do |comm|
      @@comm_export = comm
    end
  end

  # GET /commodities/1
  # GET /commodities/1.json
  def show
  end

  # GET /commodities/new
  def new
    @commodity.unit_id = current_user.unit_id
    #@commodity = Commodity.new
  end

  # GET /commodities/1/edit
  def edit
  end

  # POST /commodities
  # POST /commodities.json
  def create
    #@commodity = Commodity.new(commodity_params)

    respond_to do |format|
      if @commodity.save
        format.html { redirect_to @commodity, notice: I18n.t('controller.create_success_notice', model: '商品') }
        format.json { render action: 'show', status: :created, location: @commodity }
      else
        format.html { render action: 'new' }
        format.json { render json: @commodity.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /commodities/1
  # PATCH/PUT /commodities/1.json
  def update
    respond_to do |format|
      if @commodity.update(commodity_params)
        format.html { redirect_to @commodity, notice: I18n.t('controller.update_success_notice', model: '商品') }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @commodity.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /commodities/1
  # DELETE /commodities/1.json
  def destroy
    @commodity.destroy
    respond_to do |format|
      format.html { redirect_to commodities_url }
      format.json { head :no_content }
    end
  end

  def commodity_import
    unless request.get?
      if file = upload_commodity(params[:file]['file'])
        instance=nil
        if file.include?('.xlsx')
          instance= Roo::Excelx.new(file)
        elsif file.include?('.xls')
          instance= Roo::Excel.new(file)
        elsif file.include?('.csv')
          instance= Roo::CSV.new(file)
        end
        sheet_error = []
        instance.default_sheet = instance.sheets.first
        flash_message = "导入成功!"
        2.upto(instance.last_row) do |line|

          commodity_no = to_string(instance.cell(line,'A'))
          if commodity_no.blank?
            txt = "缺少商品编号"
            sheet_error << (instance.row(line) << txt)
            next
          end
          commodity_name = to_string(instance.cell(line,'B'))
          if commodity_name.blank?
            txt = "缺少商品名称"
            sheet_error << (instance.row(line) << txt)
            next
          end
          goodtype_name = to_string(instance.cell(line,'C'))
          if goodtype_name.blank?
            txt = "缺少商品类型"
            sheet_error << (instance.row(line) << txt)
            next
          end
          sixnine_code = to_string(instance.cell(line,'E'))
          specification_name = to_string(instance.cell(line,'F'))
          if specification_name.blank?
            txt = "缺少规格名称"
            sheet_error << (instance.row(line) << txt)
            next
          end
          desc = to_string(instance.cell(line,'G'))

          all_name = ""
          all_name << commodity_name
          all_name << specification_name

          long = instance.cell(line,'H').blank? ? 0.0 : instance.cell(line,'H')
              wide = instance.cell(line,'I').blank? ? 0.0 : instance.cell(line,'I')
              high = instance.cell(line,'J').blank? ? 0.0 : instance.cell(line,'J')
              weight = instance.cell(line,'K').blank? ? 0.0 : instance.cell(line,'K')
              volume = instance.cell(line,'L').blank? ? 0.0 : instance.cell(line,'L')

          if !(long.is_a? Float) || !(wide.is_a? Float) || !(high.is_a? Float) || !(weight.is_a? Float) || !(volume.is_a? Float)
            txt = "长宽高重量体积非数字"
            sheet_error << (instance.row(line) << txt)
            next
            # raise "导入文件第" + line.to_s + "行数据, 长宽高重量体积非数字，导入失败"
          end

          # binding.pry
          goodtype= Goodstype.accessible_by(current_ability).where(name: goodtype_name).first
          if goodtype.blank?
            txt = "商品类型不存在"
            sheet_error << (instance.row(line) << txt)
            next
            # raise "导入文件第" + line.to_s + "行数据, 商品类型不存在，导入失败"
          end
          commodity = Commodity.accessible_by(current_ability).find_by no: commodity_no
          if commodity.blank?
            commodity = Commodity.create! no: commodity_no,name: commodity_name,goodstype_id: goodtype.id,unit_id: current_user.unit.id
          end
          #binding.pry
          specification = Specification.accessible_by(current_ability).find_by commodity_id:commodity.id,name:specification_name
          if specification.blank?
            specification=Specification.create! commodity_id:commodity.id,name:specification_name,sixnine_code: sixnine_code,desc:desc,long: long,wide: wide,high: high,weight: weight,volume: volume,all_name: all_name
            # sku = goodtype.id.to_s + commodity.id.to_s + specification.id.to_s
                # specification.update_attribute(:sku,sku)
          else
            specification.update(sixnine_code: sixnine_code,desc:desc,long: long,wide: wide,high: high,weight: weight,volume: volume,all_name: all_name)
          end
        end
        redeal_with_errorcommodities(sheet_error)
        if !sheet_error.blank?
          flash_message << "有部分信息导入失败！"
        end
        flash[:notice] = flash_message

        respond_to do |format|
          format.xls {   
            if !sheet_error.blank?
              send_data(exporterrorcommodities_xls_content_for(sheet_error),  
              :type => "text/excel;charset=utf-8; header=present",  
              :filename => "Error_Commodities_#{Time.now.strftime("%Y%m%d")}.xls")  
            else
              redirect_to :action => 'index'
            end
          }
        end
      end   
    end
  end

  def redeal_with_errorcommodities(target)
    target.each do |x|
      commodity_no = to_string(x[0])
      commodity = nil
      if !commodity_no.blank?
        commodity = Commodity.accessible_by(current_ability).find_by(no: commodity_no)
      end
      if !commodity.blank?
        specification_name = to_string(x[5])
        specification = nil
        specification = Specification.accessible_by(current_ability).find_by commodity_id:commodity.id,name:specification_name
      end
      if !specification.blank? && (specification.created_at == specification.updated_at)
        specification.delete
      end
      if commodity.specifications.blank?
        commodity.delete
      end
    end
  end

  def exporterrorcommodities_xls_content_for(obj)
    xls_report = StringIO.new  
    book = Spreadsheet::Workbook.new  
    sheet1 = book.create_worksheet :name => "Commodities"  

    blue = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 10  
    red = Spreadsheet::Format.new :color => :red
    sheet1.row(0).default_format = blue 
    sheet1.row(0).concat %w{商品编号 商品名称 商品类型 SKU 69码 规格名称 规格描述 长 宽 高 重量 体积}  
    count_row = 1
    obj.each do |obj|
      sheet1[count_row,0]=obj[0]
      sheet1[count_row,1]=obj[1]
      sheet1[count_row,2]=obj[3]
      sheet1[count_row,3]=obj[3]
      sheet1[count_row,4]=obj[4]
      sheet1[count_row,5]=obj[5]
      sheet1[count_row,6]=obj[6]
      sheet1[count_row,7]=obj[7]
      sheet1[count_row,8]=obj[8]
      sheet1[count_row,9]=obj[9]
      sheet1[count_row,10]=obj[10]
      sheet1[count_row,11]=obj[11]
      count_row += 1
    end 
    book.write xls_report  
    xls_report.string  
  end

  def specification_export
      @specifications = []
      @@comm_export.each do |x|
        @specifications += x.specifications
      end
      if @specifications.blank?
         flash[:alert] = "无商品规格数据"
         redirect_to :action => 'index'
      else
        respond_to do |format|  
          format.xls {   
            send_data(specification_xls_content_for(@specifications),  
                  :type => "text/excel;charset=utf-8; header=present",  
                  :filename => "Specifications_#{Time.now.strftime("%Y%m%d")}.xls")  
          }
        end
      end
    # end
  end

  

  private
    # Use callbacks to share common setup or constraints between actions.
    # def set_commodity
    #   @commodity = Commodity.find(params[:id])
    # end

    # Never trust parameters from the scary internet, only allow the white list through.
    def commodity_params
      params[:commodity].permit!
    end


  def upload_commodity(file)
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

  def to_string(text)
    if text.is_a? Float
      return text.to_s.split('.0')[0]
    else
      return text
    end
  end

    def specification_xls_content_for(objs)  
      xls_report = StringIO.new  
      book = Spreadsheet::Workbook.new  
      sheet1 = book.create_worksheet :name => "Orders"  
    
      blue = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 10  
      sheet1.row(0).default_format = blue  
  
      sheet1.row(0).concat %w{商品编号 商品名称 商品类型 SKU 69码 规格名称 规格描述 商户 供应商 第三方商品编码 规格描述 预警数量}  
      count_row = 1
      objs.each do |obj|  
        sheet1[count_row,0]=obj.commodity.no
        sheet1[count_row,1]=obj.commodity.name
        sheet1[count_row,2]=obj.commodity.goodstype.name
        sheet1[count_row,3]=obj.sku
        sheet1[count_row,4]=obj.sixnine_code
        sheet1[count_row,5]=obj.name
        sheet1[count_row,6]=obj.desc
        sheet1[count_row,7]=""
        sheet1[count_row,8]=""
        sheet1[count_row,9]=""
        sheet1[count_row,10]=""
        sheet1[count_row,11]=""
       count_row += 1
      end  
  
      book.write xls_report  
      xls_report.string  
    end
end
