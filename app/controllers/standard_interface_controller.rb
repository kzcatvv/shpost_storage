class StandardInterfaceController < ApplicationController
  skip_before_filter :authenticate_user!
  before_filter :verify_params
  before_filter :verify_sign
  #load_and_authorize_resource

  def commodity_enter
    supplier_no = @context_hash["SUPPLIER"]
    sku = @context_hash["SKU"]
    return render json: error_builder('0005', '商品sku编码为空') if sku.blank?
    spec = @context_hash["SPEC"]
    name = @context_hash["NAME"]
    return render json: error_builder('0005', '商品名称为空') if name.blank?

    desc = @context_hash["DESC"]

    if !supplier_no.blank?
      supplier = Supplier.find_by(no: @business.no + '_' + supplier_no)

      supplier ||= Supplier.create!(no: @business.no + '_' + supplier_no, name: @business.name + '_' + supplier_no, unit: @unit)
    else
      supplier = nil
    end
    
    #price = @context_hash["PRICE"]

    thirdpartcode =  Thirdpartcode.find_by_keywords(sku, @business, @unit,supplier)
    

    if thirdpartcode.nil?
      commodity = Commodity.create! name: name, unit: @unit, no: 'need_to_edit'
      specification = Specification.create! commodity: commodity, desc: desc, name: spec, sku: 'need_to_edit', sixnine_code: 'need_to_edit'
      thirdpartcode = Thirdpartcode.create! business: @business, supplier: supplier, specification: specification, external_code: sku
    end

    if !thirdpartcode.blank?
      render json: success_builder({"SKU" => thirdpartcode.specification.sku })
    else
      render json: error_builder('9999')
    end
  end

  def order_enter

  end

  def order_query

  end

  def stock_query
  
  end

  private
  def verify_params
    @format = params[:format]
    
    return render json: error_builder('0002') if !@format.eql? 'JSON'

    @business = Business.find_by(no: params[:business])
    return render json: error_builder('0003') if @business.nil?

    @unit = Unit.find_by(no: params[:unit])
    return render json: error_builder('0004') if @unit.nil?

    @context = params[:context]
    begin
      @context_hash = ActiveSupport::JSON.decode(@context)
    rescue ActiveSupport::JSON.parse_error
      return render json: error_builder('0002')
    end
  end

  def verify_sign
    @sign = params[:sign]
    render json: error_builder('0001') if !@sign.eql? Digest::MD5.base64digest(@context + @business.secret_key)
  end

   
  def success_builder(info = nil)
    success = {'FLAG' => 'success'}
    if info.nil?
      success
    else
      success.merge info
    end
  end

  def error_builder(code, msg = nil)
    {'FLAG' => 'failure', 'CODE' => code, 'MSG' => msg.nil? ? I18n.t("standard_interface.error.#{code}") : I18n.t("standard_interface.error.#{code}") + ':' + msg }.to_json
  end
end
