class StandardInterfaceController < ApplicationController
  skip_before_filter :authenticate_user!
  before_action :verify_params
  # before_action :verify_sign
  around_action :interface_return
  #load_and_authorize_resource

  def commodity_enter
    sku = @context_hash['SKU']
    
    return error_builder('0005', '商品sku编码为空')
    # spec = @context_hash['SPEC']
    name = @context_hash['NAME']
    
    return error_builder('0005', '商品名称为空') if name.blank?

    # desc = @context_hash['DESC']

    relationship = StandardInterface.commodity_enter(@context_hash, @business, @unit)

    if !relationship.blank?
      success_builder({'SKU' => relationship.specification.sku })
    else
      error_builder('9999')
    end
  end

  def order_enter
    order_id = @context_hash['ORDER_ID']
    return error_builder('0005', '订单号为空') if order_id.blank?
    trans_sn = @context_hash['TRANS_SN']
    return error_builder('0005', '交易流水号为空') if trans_sn.blank?
    cust_name = @context_hash['CUST_NAME']
    return error_builder('0005', '收件人姓名为空') if cust_name.blank?
    addr = @context_hash['ADDR']
    return error_builder('0005', '收货人地址为空') if addr.blank?

    order_details = @context_hash['ORDER_DETAILS']
    return error_builder('0005', '商品列表为空') if order_details.blank?

    order = StandardInterface.order_enter(@context_hash, @business, @unit, @storage)

    if !order.blank?
      success_builder({'ORDER_NO' => order.no })
    else
      error_builder('9999')
    end

  end

  def order_query
    orders = StandardInterface.order_query(@context_hash, @business, @unit)

    if !orders.blank?
      deliver_details = []
      
      deliver_details = self.generalise_tracking(order.tracking_info)

      success_builder({'STATUS' => order.status, 'EXPS' => order.transport_type, 'EXPS_NO' => order.tracking_number, 'DELIVER_DETAIL' => deliver_details})
    else
      error_builder('9999')
    end
  end

  def orders_query
    type = nil
    order_nos = @context_hash['ORDER_NO']
    deliver_nos = @context_hash['DELIVER_NO']
    order_ids = @context_hash['ORDER_ID']
    trans_sns= @context_hash['TRANS_SN']
    ids = []
    order_details = []
    if !order_nos.blank?
      type = "ORDER_NO"
      ids = order_nos.split(',')
    elsif !deliver_nos.blank?
      type = "DELIVER_NO"
      ids = deliver_nos.split(',')
    elsif !order_ids.blank?
      type = "ORDER_ID"
      ids = order_ids.split(',')
    elsif !trans_sns.blank?
      type = "TRANS_SN"
      ids = trans_sns.split(',')
    end

    #orders_got = StandardInterface.orders_query(@context_hash, @business, @unit)
    
    ids.each do |id|
      order_detail = {}
      context_string = "{\"" + type + "\":\"" + id.to_s + "\"}"
      context = ActiveSupport::JSON.decode(context_string)
      orders = StandardInterface.order_query(context, @business, @unit)

      if !orders.blank?
        tracking_infos = orders.tracking_info

        orders.each do |order|
          deliver_details = order.generalise_tracking(orders.tracking_info)

          order_detail['FLAG'] = "success"
          order_detail['ORDER_ID'] = id
          order_detail['STATUS'] = order.status
          order_detail['EXPS'] = order.transport_type
          order_detail['EXPS_NO'] = order.tracking_number
          order_detail['DESC'] = ""
          order_detail['DELIVER_DETAIL'] = deliver_details
          order_details << order_detail
        end
      else
        order_detail['FLAG'] = "failure"
        order_detail['ORDER_ID'] = id
        order_detail['STATUS'] = ""
        order_detail['EXPS'] = ""
        order_detail['EXPS_NO'] = ""
        order_detail['DESC'] = "订单号不存在"
        order_detail['DELIVER_DETAIL'] = deliver_details
        order_details << order_detail
      end
    end
    {'ORDER_DETAIL' => order_details}
  end

  def stock_query
    sku = @context_hash['QUERY_ARRAY']
    return error_builder('0005', '查询列表为空') if sku.blank?

    stock_array = StandardInterface.stock_query(@context_hash, @business, @unit)

    if !stock_array.blank?
      success_builder('STOCK_ARRAY' => stock_array)
    else
      error_builder('9999')
    end
  end

  private
  def verify_params
    @format = params[:format]
    
    return error_builder('0002') if !@format.eql? 'JSON'

    @business = Business.find_by(no: params[:business])
    return error_builder('0003') if @business.nil?

    @unit = Unit.find_by(no: params[:unit])
    return error_builder('0004') if @unit.nil?

    @storage = Storage.find_by(no: params[:storage])

    @context = params[:context]

    return verify_sign

    begin
      @context_hash = ActiveSupport::JSON.decode(@context)
    rescue ActiveSupport::JSON.parse_error
      error_builder('0002')
    end
  end

  def verify_sign
    @sign = params[:sign]
    return error_builder('0001') if !@sign.eql? Digest::MD5.hexdigest(@context + @business.secret_key)
  end

  def interface_return
    if !@status.eql? false
      yield
    end
    InterfaceInfo.receive_info(request.url, @return_json, 'auto', @status)
    render json: @return_json
  end

  def success_builder(info = nil)
    @status = true
    success = {'FLAG' => 'success'}
    if info.nil?
      @return_json = success
    else
      @return_json = success.merge info
    end
    # @return_json
  end

  def error_builder(code, msg = nil)
    @status = false
    @return_json = {'FLAG' => 'failure', 'CODE' => code, 'MSG' => msg.nil? ? I18n.t("standard_interface.error.#{code}") : I18n.t("standard_interface.error.#{code}") + ':' + msg }.to_json
    # @return_json
  end
end
