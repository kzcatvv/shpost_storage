class UpDownloadsController < ApplicationController
  #before_action :set_up_download, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  def index
    @up_downloads = initialize_grid(@up_downloads, order: 'created_at',order_direction: :desc)
     #@up_download = UpDownload.all
  end

  def show
    
  end

  def new
    #@up_download = UpDownload.new
    #respond_with(@up_download)
  end

  def edit
  end

  def create
      unless request.get?
        if !@up_download.name.empty?
          if file = upload_up_download(params[:file]['file'])       
        
            @up_download = UpDownload.new(up_download_params)
        
            @up_download.url = file
            @up_download.oper_date = Time.now.strftime("%Y-%m-%d %H:%m:%S")
            @up_download.save

            flash[:alert] = "上传成功"

            redirect_to up_downloads_url
          end 
        end 
      end
  end

  def update
    #@up_download.update(up_download_params)
    #respond_with(@up_download)
  end

  def destroy
    #@up_download.destroy
    #respond_with(@up_download)
    file_path = @up_download.url
    if File.exist?(file_path)
      File.delete(file_path)

      @up_download.destroy
    end
    respond_to do |format|
      format.html { redirect_to up_downloads_url }
      format.json { head :no_content }
    end
    
  end

  def to_import
    #redirect_to up_download_import_up_downloads_url
    @up_download = UpDownload.new
    render(:action => 'up_download_import')

  end

  def up_download_import
    unless request.get?
      if file = upload_up_download(params[:file]['file'])       
        
          @up_download = UpDownload.new(up_download_params)
        
          @up_download.url = file
          @up_download.oper_date = Time.now.strftime("%Y-%m-%d %H:%m:%S")
          @up_download.save
          flash[:alert] = "上传成功"

          
          redirect_to up_downloads_url
      end   
    end
  end

  def upload_up_download(file)
     if !file.original_filename.empty?
       direct = "#{Rails.root}/public/download/"
       
       if !File.exist?(direct)
           Dir.mkdir(direct)          
       end

       filename = "#{Time.now.strftime("%Y-%m-%d %H:%m:%S")}_#{file.original_filename}"

       file_path = direct + filename
       
       File.open(file_path, "wb") do |f|
          f.write(file.read)
       end
       file_path
     end
  end

  def up_download_export
    @up_download=UpDownload.find(params[:id])
    
    if @up_download.nil?
       flash[:alert] = "无此文档模板"
       redirect_to :action => 'index'
    else
       file_path = @up_download.url
        if File.exist?(file_path)
          io = File.open(file_path)
          send_data(io.read,:filename => @up_download.name,:type => "text/excel;charset=utf-8; header=present", disposition: 'attachment')
          io.close
        else
          redirect_to up_downloads_path, :notice => '模板不存在，下载失败！'
        end
    end
  end

  def select_unit
    @storages = Storage.where(unit_id: params[:unit_id]).map{|u| [u.name,u.id]}.insert(0,"请选择")
    @business = Business.where(unit_id: params[:unit_id]).map{|u| [u.name,u.id]}.insert(0,"请选择")
    @suppliers = Supplier.where(unit_id: params[:unit_id]).map{|u| [u.name,u.id]}.insert(0,"请选择")
      #binding.pry
    respond_to do |format|
       format.js 
    end

  end

  def org_stocks_import
    unless request.get?
      if file = upload_stock(params[:file])
        StockLog.transaction do

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
            # binding.pry
            if Integer(instance.cell(3,5)) != 0 || Integer(instance.cell(3,6)) != 0 || Integer(instance.cell(3,7)) != 0
              raise "导入失败,初始结存不为0"
            end 
            sumstock = 0
            4.upto(instance.last_row) do |line|
              sumstock += Integer(instance.cell(line,'E'))
              sumstock -= Integer(instance.cell(line,'F'))
            end
            if Integer(instance.cell(instance.last_row,7)) != sumstock
              raise "导入失败,明细与期末结存不符"
            end
            @stock = Stock.create(shelf_id: params[:si_shelfid],business_id: params[:si_businessid],supplier_id: params[:si_supplierid],specification_id: params[:si_specificationid],actual_amount: sumstock,virtual_amount: sumstock)
            
            4.upto(instance.last_row) do |line|
              if Integer(instance.cell(line,'E')) < 0
                @stocklog = StockLog.create(user_id: current_user.id,stock: @stock,operation: 'b2b_stock_out',status: 'checked',amount: -Integer(instance.cell(line,'E')),checked_at: instance.cell(line,'B').to_s.to_time,created_at: instance.cell(line,'B').to_s.to_time,updated_at: instance.cell(line,'B').to_s.to_time,operation_type: 'out',shelf_id: params[:si_shelfid],business_id: params[:si_businessid],supplier_id: params[:si_supplierid],specification_id: params[:si_specificationid]) 
              end
              if Integer(instance.cell(line,'E')) > 0
                @stocklog = StockLog.create(user_id: current_user.id,stock: @stock,operation: 'purchase_stock_in',status: 'checked',amount: Integer(instance.cell(line,'E')),checked_at: instance.cell(line,'B').to_s.to_time,created_at: instance.cell(line,'B').to_s.to_time,updated_at: instance.cell(line,'B').to_s.to_time,operation_type: 'in',shelf_id: params[:si_shelfid],business_id: params[:si_businessid],supplier_id: params[:si_supplierid],specification_id: params[:si_specificationid]) 
              end
              if Integer(instance.cell(line,'F')) < 0
                @stocklog = StockLog.create(user_id: current_user.id,stock: @stock,operation: 'purchase_stock_in',status: 'checked',amount: -Integer(instance.cell(line,'F')),checked_at: instance.cell(line,'B').to_s.to_time,created_at: instance.cell(line,'B').to_s.to_time,updated_at: instance.cell(line,'B').to_s.to_time,operation_type: 'in',shelf_id: params[:si_shelfid],business_id: params[:si_businessid],supplier_id: params[:si_supplierid],specification_id: params[:si_specificationid]) 
              end
              if Integer(instance.cell(line,'F')) > 0
                @stocklog = StockLog.create(user_id: current_user.id,stock: @stock,operation: 'b2b_stock_out',status: 'checked',amount: Integer(instance.cell(line,'F')),checked_at: instance.cell(line,'B').to_s.to_time,created_at: instance.cell(line,'B').to_s.to_time,updated_at: instance.cell(line,'B').to_s.to_time,operation_type: 'out',shelf_id: params[:si_shelfid],business_id: params[:si_businessid],supplier_id: params[:si_supplierid],specification_id: params[:si_specificationid]) 
              end
            end

            flash[:alert] = "导入成功"
          rescue Exception => e
            Rails.logger.error e.backtrace
            flash[:alert] = e.message
            raise ActiveRecord::Rollback
          end
        end
      end   
    end
  end

  def org_single_stocks_import
    unless request.get?
      if file = upload_stock(params[:file])
        StockLog.transaction do

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
                        
            2.upto(instance.last_row) do |line|
              # binding.pry
              if Integer(instance.cell(line,'E')) > 0
                if !instance.cell(line,'A').to_s.blank?
                  @relationship = Relationship.where("external_code = ?",instance.cell(line,'A').to_s).first
                else
                  @relationship = nil
                end
                  if @relationship.blank?
                    if instance.cell(line,'B').to_s.blank? || instance.cell(line,'G').to_s.blank? || instance.cell(line,'I').to_s.blank?
                      raise "导入文件第" + line.to_s + "行数据, 69码或商品编号或供应商编号为空，导入失败"
                    else
                      @specification = Specification.where("sixnine_code = ?",Integer(instance.cell(line,'B')).to_s).first
                      @business = Business.where("no = ?",Integer(instance.cell(line,'G')).to_s).first
                      @supplier = Supplier.where("no = ?",Integer(instance.cell(line,'I')).to_s).first
                      @relationship = Relationship.where("business_id = ? and supplier_id = ? and specification_id = ?",@business.id,@supplier.id,@specification.id).first
                    end
                  end
                  if @relationship.blank?
                    raise "导入文件第" + line.to_s + "行数据, 未找到该商品信息，导入失败"
                  end
                  @shelf = Shelf.where("shelf_code = ?",instance.cell(line,'D').to_s).first
                  if @shelf.blank?
                    raise "导入文件第" + line.to_s + "行数据, 未找到该货架信息，导入失败"
                  end
                  @stock = Stock.where("relationship_id = ? and shelf_id = ?",@relationship.id,@shelf.id).first
                  if @stock.blank?
                    @stock = Stock.create(shelf: @shelf,business: @relationship.business,supplier: @relationship.supplier,specification: @relationship.specification,actual_amount: Integer(instance.cell(line,'E')),virtual_amount: Integer(instance.cell(line,'E')))
                  else
                    @stock.update(actual_amount: @stock.actual_amount + Integer(instance.cell(line,'E')),virtual_amount: @stock.virtual_amount + Integer(instance.cell(line,'E')) )
                  end
                  @stocklog = StockLog.create(user_id: current_user.id,stock: @stock,operation: 'purchase_stock_in',status: 'checked',amount: Integer(instance.cell(line,'E')),checked_at: Time.now,operation_type: 'in',shelf: @shelf,business: @relationship.business,supplier: @relationship.supplier,specification: @relationship.specification) 
                
              end
            end

            flash[:alert] = "导入成功"
          rescue Exception => e
            Rails.logger.error e.backtrace
            flash[:alert] = e.message
            raise ActiveRecord::Rollback
          end
        end
      end   
    end
  end

  def upload_stock(file)
    if !file.original_filename.empty?
      direct = "#{Rails.root}/upload/stocks_import/"
      filename = "#{Time.now.to_f}_#{file.original_filename}"

      file_path = direct + filename
      File.open(file_path, "wb") do |f|
        f.write(file.read)
      end
      file_path
    end
  end
  

  private
    def set_up_download
      @up_download = UpDownload.find(params[:id])
    end

    def up_download_params
      params.require(:up_download).permit(:name, :use, :desc, :ver_no)
      
    end
end
