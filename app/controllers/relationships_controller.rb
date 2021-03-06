class RelationshipsController < ApplicationController
  #before_action :set_relationship, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  
  autocomplete :relationship, :name


  # GET /relationships
  # GET /relationships.json
  def index
    #@relationships = Relationship.all
    @relationships_grid = initialize_grid(@relationships,
      :order => 'relationships.id',
      :order_direction => 'desc',
      include: [:business, :specification, :supplier],
      :name => 'relationships',
      :enable_export_to_csv => true,
      :csv_file_name => 'relationships')

    export_grid_if_requested

  end

  # GET /relationships/1
  # GET /relationships/1.json
  def show
  end

  # GET /relationships/new
  def new
    #@relationship = Relationship.new
  end

  # GET /relationships/1/edit
  def edit
    #binding.pry
    set_autocom_update(@relationship)
  end

  # POST /relationships
  # POST /relationships.json
  def create
    #@relationship = Relationship.new(relationship_params)
    #@relationship.specification_id = params[:specification_id][:id]
    respond_to do |format|
      if @relationship.save
        format.html { redirect_to @relationship, notice: I18n.t('controller.create_success_notice', model: '对应关系')}
        format.json { render action: 'show', status: :created, location: @relationship }
      else
        format.html { render action: 'new' }
        format.json { render json: @relationship.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /relationships/1
  # PATCH/PUT /relationships/1.json
  def update
    respond_to do |format|
      if @relationship.update(relationship_params)
        format.html { redirect_to @relationship, notice: I18n.t('controller.update_success_notice', model: '对应关系') }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @relationship.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /relationships/1
  # DELETE /relationships/1.json
  def destroy
    @relationship.destroy
    respond_to do |format|
      format.html { redirect_to relationships_url }
      format.json { head :no_content }
    end
  end

  def select_commodities
      #@objid = params[:object_id]

      @commodities = Commodity.where(goodstype_id: params[:goodstype_id]).accessible_by(current_ability).map{|u| [u.name,u.id]}.insert(0,"请选择")
      @objid = params[:object_id]+"_specification_id"
      @specifications = {"请选择" => 0 }.map
      #binding.pry
      respond_to do |format|
        format.js 
      end

  end

  def select_specifications
      @objid = params[:object_id]+"_specification_id"
      @specifications = Specification.where(commodity_id: params[:commodity_id]).accessible_by(current_ability).map{|u| [u.name,u.id]}.insert(0,"请选择")
      #binding.pry
      respond_to do |format|
        format.js 
      end
  end

  # def relationship_import
  #   unless request.get?
  #     if file = upload_relationship(params[:file]['file'])       
  #       Relationship.transaction do
  #         begin
  #           instance=nil
  #           if file.include?('.xlsx')
  #             instance= Roo::Excelx.new(file)
  #           elsif file.include?('.xls')
  #             instance= Roo::Excel.new(file)
  #           elsif file.include?('.csv')
  #             instance= Roo::CSV.new(file)
  #           end
  #           instance.default_sheet = instance.sheets.first

  #           2.upto(instance.last_row) do |line|
  #             specification = Specification.accessible_by(current_ability).find_by sku: to_string(instance.cell(line,'D'))
  #             if specification.blank?
  #               raise "导入文件第" + line.to_s + "行数据, 商品规格不存在，导入失败"
  #             end
  #             business = Business.accessible_by(current_ability).find_by name: to_string(instance.cell(line,'H'))
  #             if business.blank?
  #               raise "导入文件第" + line.to_s + "行数据, 商户不存在，导入失败"
  #             end
  #             supplier = Supplier.accessible_by(current_ability).find_by name: to_string(instance.cell(line,'I'))
  #             if supplier.blank?
  #               raise "导入文件第" + line.to_s + "行数据, 供应商不存在，导入失败"
  #             end
  #             relationship = Relationship.accessible_by(current_ability).find_by business_id: business.id, specification_id: specification.id, supplier_id: supplier.id
  #             if relationship.nil?
  #               Relationship.create! business_id: business.id, supplier_id: supplier.id, specification_id: specification.id, external_code: to_string(instance.cell(line,'J')), spec_desc: to_string(instance.cell(line,'K')), warning_amt: instance.cell(line,'L').to_i
  #             else
  #               Relationship.update relationship.id ,business_id: business.id, supplier_id: supplier.id, specification_id: specification.id, external_code: to_string(instance.cell(line,'J')), spec_desc: to_string(instance.cell(line,'K')), warning_amt: instance.cell(line,'L').to_i
  #             end
  #           end
  #           flash[:alert] = "导入成功"
  #         rescue Exception => e
  #           flash[:alert] = e.message
  #           raise ActiveRecord::Rollback
  #         end
  #       end
  #     end   
  #   end
  # end

  def relationship_import
    unless request.get?
      if file = upload_relationship(params[:file]['file'])       
        instance=nil
        if file.include?('.xlsx')
          instance= Roo::Excelx.new(file)
        elsif file.include?('.xls')
          instance= Roo::Excel.new(file)
        elsif file.include?('.csv')
          instance= Roo::CSV.new(file)
        end
        sheet_error = []
        rowarr = []
        instance.default_sheet = instance.sheets.first
        flash_message = "导入成功!"
        2.upto(instance.last_row) do |line|
          rowarr = instance.row(line)
          sku = to_string(rowarr[3])
          business_name = to_string(rowarr[7])
          supplier_name = to_string(rowarr[8])
          
          if sku.blank?
            txt = "缺少SKU"
            sheet_error << (rowarr << txt)
            next
          end
          specification = Specification.accessible_by(current_ability).find_by sku: sku
          if specification.blank?
            txt = "商品规格不存在"
            sheet_error << (rowarr << txt)
            next
            # raise "导入文件第" + line.to_s + "行数据, 商品规格不存在，导入失败"
          end
          if business_name.blank?
            txt = "缺少商户"
            sheet_error << (rowarr << txt)
            next
          end
          business = Business.accessible_by(current_ability).find_by name: business_name
          if business.blank?
            txt = "商户不存在"
            sheet_error << (rowarr << txt)
            next
            # raise "导入文件第" + line.to_s + "行数据, 商户不存在，导入失败"
          end
          if supplier_name.blank?
            txt = "缺少供应商"
            sheet_error << (rowarr << txt)
            next
          end
          supplier = Supplier.accessible_by(current_ability).find_by name: supplier_name
          if supplier.blank?
            txt = "供应商不存在"
            sheet_error << (rowarr << txt)
            next
            # raise "导入文件第" + line.to_s + "行数据, 供应商不存在，导入失败"
          end
          relationship = Relationship.accessible_by(current_ability).find_by business_id: business.id, specification_id: specification.id, supplier_id: supplier.id
          if relationship.nil?
            Relationship.create! business_id: business.id, supplier_id: supplier.id, specification_id: specification.id, external_code: to_string(rowarr[9]), spec_desc: to_string(rowarr[10]), warning_amt: rowarr[11].to_i
          else
            Relationship.update relationship.id ,business_id: business.id, supplier_id: supplier.id, specification_id: specification.id, external_code: to_string(rowarr[9]), spec_desc: to_string(rowarr[10]), warning_amt: rowarr[11].to_i
          end
        end

        if !sheet_error.blank?
          flash_message << "有部分信息导入失败！"
        end
        flash[:notice] = flash_message

        if !sheet_error.blank?
          send_data(exporterrorrelationships_xls_content_for(sheet_error),  
          :type => "text/excel;charset=utf-8; header=present",  
          :filename => "Error_Relationships_#{Time.now.strftime("%Y%m%d")}.xls")  
        else
          redirect_to :action => 'index'
        end
      end   
    end
  end

  def exporterrorrelationships_xls_content_for(obj)
    xls_report = StringIO.new  
    book = Spreadsheet::Workbook.new  
    sheet1 = book.create_worksheet :name => "Relationships"  

    blue = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 10  
    red = Spreadsheet::Format.new :color => :red
    sheet1.row(0).default_format = blue 
    sheet1.row(0).concat %w{商品编号 商品名称 商品类型 SKU 69码 规格名称 规格描述 商户 供应商 第三方商品编码 规格描述 预警数量} 
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
      sheet1[count_row,12]=obj[12]
      count_row += 1
    end 
    book.write xls_report  
    xls_report.string  
  end 

  def specification_export
    @specifications=Specification.accessible_by(current_ability).all
    if @specifications.nil?
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
  end

  def upload_relationship(file)
     if !file.original_filename.empty?
       direct = "#{Rails.root}/upload/relationship/"
       filename = "#{Time.now.to_f}_#{file.original_filename}"

       file_path = direct + filename
       File.open(file_path, "wb") do |f|
          f.write(file.read)
       end
       file_path
     end
  end

  def autocomplete_rel_name
    term = params[:term]
    
    # country = params[:country]
    rels = Relationship.includes(:specification).where("specifications.name LIKE ? ", "%#{term}%")
    render :json => rels.map { |rel| {:id => rel.id, :label => rel.business.name+rel.supplier.name+rel.specification.name, :value => rel.business.name+rel.supplier.name+rel.specification.name} }
  end

  def autocomplete_rel_name_byrel
    term = params[:term]
    invdtls = params[:inv_type_dtl].split(",")
    # country = params[:country]
    rels = Relationship.includes(:specification).where("specifications.name LIKE ? and relationships.id in (?)", "%#{term}%",invdtls)
    render :json => rels.map { |rel| {:id => rel.id, :label => rel.business.name+rel.supplier.name+rel.specification.name, :value => rel.business.name+rel.supplier.name+rel.specification.name} }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_relationship
      @relationship = Relationship.find(params[:id])
    end

    

    # Never trust parameters from the scary internet, only allow the white list through.
    def relationship_params
      params.require(:relationship).permit(:business_id, :supplier_id, :specification_id, :external_code, :spec_desc, :warning_amt)
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

  def to_string(text)
    if text.is_a? Float
      return text.to_s.split('.0')[0]
    else
      return text
    end
  end
end
