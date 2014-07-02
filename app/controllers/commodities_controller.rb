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
        format.html { redirect_to @commodity, notice: 'Commodity was successfully created.' }
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
        format.html { redirect_to @commodity, notice: 'Commodity was successfully updated.' }
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

  private
    # Use callbacks to share common setup or constraints between actions.
    # def set_commodity
    #   @commodity = Commodity.find(params[:id])
    # end

    # Never trust parameters from the scary internet, only allow the white list through.
    def commodity_params
      params[:commodity].permit!
    end

def commodity_import
    
    unless request.get?
      if file = upload_commodity(params[:file]['file'])
     #   puts xxx
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
            puts 111111
            instance.default_sheet = instance.sheets.first

            2.upto(instance.last_row) do |line|
              puts 10001
             # all_name = ""
             # all_name << instance.cell(line,'B').to_s
             # all_name << instance.cell(line,'F').to_s
             # puts  all_name
              # binding.pry
              goodtype= Goodstype.where(name:instance.cell(line,'C').to_s).first
              puts  10002
              commodity = Commodity.create! no:instance.cell(line,'A'),name: instance.cell(line,'B'),goodstype_id: goodtype.id,unit_id: current_user.unit.id
              puts  10003
             # specification=Specifications.create! commodity_id:commodity.id,name:instance.cell(line,'F'),sixnine_code:instance.cell(line,'E'),desc:instance.cell(line,'G'),sku:instance.cell(line,'D'),long:instance.cell(line,'H'),wide:instance.cell(line,'I'),high:instance.cell(line,'J'),weight:instance.cell(line,'K'),volumn:instance.cell(line,'L'),all_name:all_name
              puts  10004
            end
            flash[:alert] = "导入成功"
          rescue Exception => e
            flash[:alert] = "导入失败"
            raise ActiveRecord::Rollback
          end
        end
      end   
    end
  end

 def upload_commodity(file)
    if !file.original_filename.empty?
      puts 99999
      direct = "#{Rails.root}/upload/shelf/"
      filename = "#{Time.now.to_f}_#{file.original_filename}"
      file_path = direct + filename
      puts file_path
      File.open(file_path, "wb") do |f|
        f.write(file.read)
      end
      file_path
    end
  end




end
