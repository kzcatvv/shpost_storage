class ShelvesController < ApplicationController
  # before_action :set_shelf, only: [:show, :edit, :update, :destroy]
  before_filter :find_current_storage
  load_and_authorize_resource :shelf

  autocomplete :shelf, :shelf_code

  def autocomplete_shelf_shelf_code
    term = params[:term]
    # brand_id = params[:brand_id]
    # country = params[:country]
    shelves = Shelf.where(area_id: Area.where(storage: current_storage).ids).where("shelf_code LIKE ? and shelf_type!='broken' ", "%#{term}%").order(:shelf_code).all
    render :json => shelves.map { |shelf| {:id => shelf.id, :label => shelf.shelf_code, :value => shelf.shelf_code} }
  end

  def autocomplete_pick_shelf_code
    term = params[:term]
    # brand_id = params[:brand_id]
    # country = params[:country]
    shelves = Shelf.where(area_id: Area.where(storage: current_storage).ids).where("shelf_code LIKE ? and shelf_type='pick' ", "%#{term}%").order(:shelf_code).all
    render :json => shelves.map { |shelf| {:id => shelf.id, :label => shelf.shelf_code, :value => shelf.shelf_code} }
  end

  def autocomplete_bad_shelf_code
    term = params[:term]
    # brand_id = params[:brand_id]
    # country = params[:country]
    shelves = Shelf.where(area_id: Area.where(storage: current_storage).ids).where("shelf_code LIKE ? and shelf_type='broken' ", "%#{term}%").order(:shelf_code).all
    render :json => shelves.map { |shelf| {:id => shelf.id, :label => shelf.shelf_code, :value => shelf.shelf_code} }
  end

  def autocomplete_shelf_code_by_stockimp
    term = params[:term]
    storageid = params[:storage_id]
    # brand_id = params[:brand_id]
    # country = params[:country]
    shelves = Shelf.where(area_id: Area.where(storage_id: storageid).ids).where("shelf_code LIKE ? and shelf_type!='broken' ", "%#{term}%").order(:shelf_code).all
    render :json => shelves.map { |shelf| {:id => shelf.id, :label => shelf.shelf_code, :value => shelf.shelf_code} }
  end

  def find_current_storage
    @areas = Area.where("storage_id = ?", session[:current_storage])
    @shelves = Shelf.where("area_id in (?)", @areas.ids)
  end

  # GET /shelves
  # GET /shelves.json
  def index
    @shelves_grid = initialize_grid(@shelves,
      :order => 'shelves.id',
      :order_direction => 'desc',
      :include => :area)
  end

  # GET /shelves/1
  # GET /shelves/1.json
  def show
  end

  # GET /shelves/new
  def new
  end

  # GET /shelves/1/edit
  def edit
  end

  # POST /shelves
  # POST /shelves.json
  def create
    @shelf = Shelf.new(shelf_params)
    @shelf.shelf_code = setShelfCode(shelf_params)
    @shelf.shelf_type = Area.find(@shelf.area_id).area_type
    # @shelf.shelf_code = @areas.find(shelf_params[:area_id]).area_code
    # @shelf.shelf_code << "-" << change(shelf_params[:area_length])
    # @shelf.shelf_code << "-" << change(shelf_params[:area_width])
    # @shelf.shelf_code << "-" << change(shelf_params[:area_height])
    # @shelf.shelf_code << "-" << change(shelf_params[:shelf_row])
    # @shelf.shelf_code << "-" << change(shelf_params[:shelf_column])

    respond_to do |format|
      if @shelf.save
        format.html { redirect_to @shelf, notice: I18n.t('controller.create_success_notice', model: '货架')}
        format.json { render action: 'show', status: :created, location: @shelf }
      else
        format.html { render action: 'new' }
        format.json { render json: @shelf.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /shelves/1
  # PATCH/PUT /shelves/1.json
  def update
    @shelf.shelf_code = setShelfCode(shelf_params)
    #@shelf.is_bad = Area.find(params[:shelf][:area_id]).is_bad
    #@shelf.shelf_type = Area.find(params[:shelf][:area_id]).area_type
    @shelf.shelf_type = Area.find(@shelf.area_id).area_type
    # @shelf.shelf_code = @areas.find(shelf_params[:area_id]).area_code
    # @shelf.shelf_code << "-" << change(shelf_params[:area_length])
    # @shelf.shelf_code << "-" << change(shelf_params[:area_width])
    # @shelf.shelf_code << "-" << change(shelf_params[:area_height])
    # @shelf.shelf_code << "-" << change(shelf_params[:shelf_row])
    # @shelf.shelf_code << "-" << change(shelf_params[:shelf_column])
    
    respond_to do |format|
      if @shelf.update(shelf_params)
        format.html { redirect_to @shelf, notice: I18n.t('controller.update_success_notice', model: '货架') }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @shelf.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shelves/1
  # DELETE /shelves/1.json
  def destroy
    @shelf.destroy
    respond_to do |format|
      format.html { redirect_to shelves_url }
      format.json { head :no_content }
    end
  end


  def shelf_import
    unless request.get?
      if file = upload_shelf(params[:file]['file'])
        Shelf.transaction do
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
              storage = Storage.accessible_by(current_ability).where(name: instance.cell(line,'A').to_s).first
              area=Area.accessible_by(current_ability).where(storage: storage, area_code: instance.cell(line,'B').to_s).first
              shelfcode = ""
              shelfcode << instance.cell(line,'B').to_s
              shelfcode << change(to_string(instance.cell(line,'C').to_s))
              shelfcode << change(to_string(instance.cell(line,'D').to_s))
              shelfcode << change(to_string(instance.cell(line,'E').to_s))
              shelfcode << change(to_string(instance.cell(line,'F').to_s))
              shelfcode << change(to_string(instance.cell(line,'G').to_s))
              # binding.pry
              shelf = Shelf.create! area_id: area.id,area_length: to_string(instance.cell(line,'C')),area_width: to_string(instance.cell(line,'D')), area_height:to_string(instance.cell(line,'E')), shelf_row:to_string(instance.cell(line,'F')), shelf_column:to_string(instance.cell(line,'G')),max_weight: instance.cell(line,'H').to_i, max_volume: instance.cell(line,'I').to_i,desc: instance.cell(line,'J'),shelf_code:shelfcode,shelf_type: area.area_type
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

  def upload_shelf(file)
    if !file.original_filename.empty?
      direct = "#{Rails.root}/upload/shelf/"
      filename = "#{Time.now.to_f}_#{file.original_filename}"
      file_path = direct + filename
      File.open(file_path, "wb") do |f|
        f.write(file.read)
      end
      file_path
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_shelf
      @shelf = Shelf.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def shelf_params
      params.require(:shelf).permit(:area_id, :shelf_code, :desc, :area_length, :area_width, :area_height, :shelf_row, :shelf_column, :max_weight, :max_volume, :shelf_type)
    end

    def change(text)
      # str_space = "%02s" % text
      # str_0 = str_space.tr(" ","0");
      # if str_0.nil?
      #   str_space
      # else
      #   str_0
      # end
      text.blank?? "" : ('-'<<text)

    end

    def to_string(text)
      text.to_s.split('.0')[0]
    end

    def setShelfCode(shelf_params)
      shelf_code = @areas.find(shelf_params[:area_id]).area_code
      shelf_code << change(shelf_params[:area_length])
      shelf_code << change(shelf_params[:area_width])
      shelf_code << change(shelf_params[:area_height])
      shelf_code << change(shelf_params[:shelf_row])
      shelf_code << change(shelf_params[:shelf_column])
    end

end
