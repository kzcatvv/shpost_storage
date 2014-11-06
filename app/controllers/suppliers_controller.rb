class SuppliersController < ApplicationController
  load_and_authorize_resource

  # GET /suppliers
  # GET /suppliers.json
  def index
    #@suppliers = Supplier.all
    @suppliers = initialize_grid(@suppliers)
  end

  # GET /suppliers/1
  # GET /suppliers/1.json
  def show
  end

  # GET /suppliers/new
  def new
    #@supplier = Supplier.new
    #@supplier.unit_id=2
    #@supplier.build(unit_id: current_user.unit)
  end

  # GET /suppliers/1/edit
  def edit
  end

  # POST /suppliers
  # POST /suppliers.json
  def create
    

    respond_to do |format|
      if @supplier.save
        format.html { redirect_to @supplier, notice: I18n.t('controller.create_success_notice', model: '供应商') }
        format.json { render action: 'show', status: :created, location: @supplier }
      else
        format.html { render action: 'new' }
        format.json { render json: @supplier.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /suppliers/1
  # PATCH/PUT /suppliers/1.json
  def update
    respond_to do |format|
      if @supplier.update(supplier_params)
        format.html { redirect_to @supplier, notice: I18n.t('controller.update_success_notice', model: '供应商') }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @supplier.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /suppliers/1
  # DELETE /suppliers/1.json
  def destroy
    @supplier.destroy
    respond_to do |format|
      format.html { redirect_to suppliers_url }
      format.json { head :no_content }
    end
  end

  def supplier_import
    unless request.get?
      if file = upload_supplier(params[:file]['file'])       
        Supplier.transaction do
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
              supplier_no = instance.cell(line,'A').to_s.split('.0')[0]
              supplier_name = instance.cell(line,'B').to_s
              supplier_addr = instance.cell(line,'C').to_s
              supplier_tel = instance.cell(line,'D').to_s.split('.0')[0]

              supplier = Supplier.create(no: supplier_no, name: supplier_name, address: supplier_addr, phone: supplier_tel, unit_id: current_storage.unit_id)

              contact_i = 1
              while !instance.cell(line, contact_i*4 + 1).to_s.blank? do
                contact_name = instance.cell(line, contact_i*4 + 1).to_s
                contact_email = instance.cell(line, contact_i*4 + 2).to_s
                contact_phone = instance.cell(line, contact_i*4 + 3).to_s.split('.0')[0]
                contact_desc = instance.cell(line, contact_i*4 + 4).to_s

                contact = Contact.create(name: contact_name, email: contact_email, phone: contact_phone, desc: contact_desc, supplier_id: supplier.id)
                contact_i = contact_i + 1
              end
            end
            flash[:alert] = "导入成功"
          rescue Exception => e
            flash[:alert] = e.message
            raise ActiveRecord::Rollback
          end
        end
      end   
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_supplier
      @supplier = Supplier.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def supplier_params
      params[:supplier].permit!
    end

    def upload_supplier(file)
      if !file.original_filename.empty?
        direct = "#{Rails.root}/upload/supplier/"
        filename = "#{Time.now.to_f}_#{file.original_filename}"

        file_path = direct + filename
        File.open(file_path, "wb") do |f|
           f.write(file.read)
        end
        file_path
      end
    end
end
