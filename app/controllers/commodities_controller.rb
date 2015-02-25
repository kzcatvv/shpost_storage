class CommoditiesController < ApplicationController
  load_and_authorize_resource

  # GET /commodities
  # GET /commodities.json
  def index
    @commodities = initialize_grid(@commodities,
                   :order => 'commodities.id',
                   :order_direction => 'desc'
                  
)
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
        Commodity.transaction do
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

              commodity_no = to_string(instance.cell(line,'A'))
              commodity_name = to_string(instance.cell(line,'B'))
              goodtype_name = to_string(instance.cell(line,'C'))
              sixnine_code = to_string(instance.cell(line,'E'))
              specification_name = to_string(instance.cell(line,'F'))
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
                raise "导入文件第" + line.to_s + "行数据, 长宽高重量体积非数字，导入失败"
              end

              # binding.pry
              goodtype= Goodstype.accessible_by(current_ability).where(name: goodtype_name).first
              if goodtype.blank?
                raise "导入文件第" + line.to_s + "行数据, 商品类型不存在，导入失败"
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
end
