class StandardInterfaceController < ApplicationController
  skip_before_filter :authenticate_user!
  before_filter :verify_params
  before_filter :verify_sign
  #load_and_authorize_resource

  def commodity_enter
    # supplier_no = @context_hash['SUPPLIER']
    sku = @context_hash['SKU']
    return render json: error_builder('0005', '商品sku编码为空') if sku.blank?
    # spec = @context_hash['SPEC']
    name = @context_hash['NAME']
    return render json: error_builder('0005', '商品名称为空') if name.blank?

    # desc = @context_hash['DESC']

    thirdpartcode = StandardInterface.commodity_enter(@context_hash, @business, @unit)

    if !thirdpartcode.blank?
      render json: success_builder({'SKU' => thirdpartcode.specification.sku })
    else
      render json: error_builder('9999')
    end
  end

  def order_enter
    order_id = @context_hash['ORDER_ID']
    return render json: error_builder('0005', '订单号为空') if order_id.blank?
    trans_sn = @context_hash['TRANS_SN']
    return render json: error_builder('0005', '交易流水号为空') if trans_sn.blank?
    cust_name = @context_hash['CUST_NAME']
    return render json: error_builder('0005', '收件人姓名为空') if cust_name.blank?
    addr = @context_hash['ADDR']
    return render json: error_builder('0005', '收货人地址为空') if addr.blank?

    order_details = @context_hash['ORDER_DETAILS']
    return render json: error_builder('0005', '商品列表为空') if order_details.blank?

    order = StandardInterface.order_enter(@context_hash, @business, @unit)

    if !order.blank?
      render json: success_builder({'ORDER_NO' => order.no })
    else
      render json: error_builder('9999')
    end

  end

  def order_query
    order_got = StandardInterface.order_query(@context_hash, @business, @unit)

    if !order_got.blank?
      if order_got.is_a? Order
        render json: success_builder({'STATUS' => order_got.status, 'EXPS' => order_got.transport_type, 'EXPS_NO' => order_got.tracking_number})
      else
        render json: success_builder({'STATUS' => order_got.order.status, 'EXPS' => order_got.transport_type, 'EXPS_NO' => order_god.tracking_number})
      end
    else
      render json: error_builder('9999')
    end
  end

  def stock_query
    sku = @context_hash['SKU']
    return render json: error_builder('0005', '商品sku编码为空') if sku.blank?

    amount = StandardInterface.order_stock(@context_hash, @business, @unit)

    if !amount.blank?
      render json: success_builder({'AMT' => amount })
    else
      render json: error_builder('9999')
    end
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
