class StandardInterfaceController < ApplicationController
  skip_before_filter :authenticate_user!
  before_action :verify_params
  # before_action :verify_sign
  around_action :interface_return
  skip_before_filter :verify_authenticity_token 
  #load_and_authorize_resource

  def commodity_enter
    return error_builder('0005', '商品sku编码为空') if @context_hash['BUSINESS_SKU'].blank?
    # spec = @context_hash['SPEC']

    return error_builder('0005', '商品编号为空') if @context_hash['COMMODITY_NO'].blank?

    return error_builder('0005', '商品名称为空') if @context_hash['COMMODITY'].blank? && @context_hash['COMMODITY_EN'].blank?
    
    return error_builder('0005', '规格名称为空') if @context_hash['SPEC'].blank? && @context_hash['SPEC_EN'].blank?

    # desc = @context_hash['DESC']

    relationship = StandardInterface.commodity_enter(@context_hash, @business, @unit)

    if !relationship.blank?
      success_builder({'BUSINESS_SKU' => relationship.external_code, 'SKU' => relationship.barcdoe })
    else
      error_builder('9999')
    end
  end

  def order_enter
    # order_id = @context_hash['ORDER_ID']
    return error_builder('0005', '订单号为空') if @context_hash['ORDER_ID'].blank?
    # trans_sn = @context_hash['TRANS_SN']
    # return error_builder('0005', '交易流水号为空') if trans_sn.blank?
    # cust_name = @context_hash['CUST_NAME']
    return error_builder('0005', '收件人姓名为空') if @context_hash['CUST_NAME'].blank? && @context_hash['LOCAL_NAME'].blank?
    # addr = @context_hash['ADDR']
    return error_builder('0005', '收货人地址为空') if @context_hash['ADDR'].blank? && @context_hash['LOCAL_ADDR'].blank?

    # order_details = @context_hash['ORDER_DETAILS']
    return error_builder('0005', '商品列表为空') if @context_hash['ORDER_DETAILS'].blank?

    order = StandardInterface.order_enter(@context_hash, @business, @unit, @storage)
    if !order.blank?
      if order.is_a? Order
        success_builder({'ORDER_NO' => order.batch_no, 'DELIVER_NO' => order.tracking_number })
      else
        return error_builder('0006')
      end
    else
      return error_builder('9999')
    end
  end

  # def order_query
  #   orders = StandardInterface.order_query(@context_hash, @business, @unit)

  #   if !orders.blank?
  #     deliver_details = []
      
  #     deliver_details = self.generalise_tracking(order.tracking_info)

  #     success_builder({'STATUS' => order.status, 'EXPS' => order.transport_type, 'EXPS_NO' => order.tracking_number, 'DELIVER_DETAIL' => deliver_details})
  #   else
  #     error_builder('9999')
  #   end
  # end

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
      context_string = "{\"" + type + "\":\"" + id.to_s + "\"}"
      context = ActiveSupport::JSON.decode(context_string)
      orders = StandardInterface.order_query(context, @business, @unit)

      if !orders.blank?
        # tracking_infos = orders.tracking_info

        orders.each do |order|
          order_detail = {}
          deliver_details = StandardInterface.generalise_tracking(order.tracking_info)

          order_detail['FLAG'] = "success"
          order_detail['ORDER_NO'] = order.batch_no
          order_detail['DELIVER_NO'] = order.tracking_number
          order_detail['ORDER_ID'] = order.business_order_id
          order_detail['TRANS_SN'] = order.business_trans_no
          order_detail['STATUS'] = order.status
          order_detail['EXPS'] = order.transport_type
          order_detail['EXPS_NO'] = order.tracking_number
          order_detail['DESC'] = ""
          order_detail['WEIGHT'] = order.total_weight
          order_detail['VOLUME'] = order.volume
          # todo
          order_detail['STATUS_CODE'] = 10
          
          order_detail['DELIVER_DETAIL'] = deliver_details

          order_details << order_detail
        end
      else
        order_detail = {}
        order_detail['FLAG'] = "failure"
        order_detail['ORDER_ID'] = id
        # order_detail['STATUS'] = ""
        # order_detail['EXPS'] = ""
        # order_detail['EXPS_NO'] = ""
        order_detail['CODE'] = "0005"
        order_detail['MSG'] = "订单号不存在"
        # order_detail['DELIVER_DETAIL'] = ""
        order_details << order_detail
      end
    end

    success_builder({'ORDER_DETAIL' => order_details})
  end

  def stock_query
    return error_builder('0005', '查询列表为空') if @context_hash['QUERY_ARRY'].blank?

    stocks = StandardInterface.stock_query(@context_hash, @business, @unit, @storage)

    success_builder('STOCKS' => stocks)
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

    begin
      @context_hash = ActiveSupport::JSON.decode(@context)
    rescue ActiveSupport::JSON.parse_error
      return error_builder('0002')
    end
    
    return verify_sign

  end

  def verify_sign
    @sign = params[:sign]
    return error_builder('0001') if !@sign.eql? Digest::MD5.hexdigest("#{@context}#{@business.secret_key}")
  end

  def interface_return
    if !@status.eql? false
      yield
    end
    InterfaceInfo.receive_info(request.url, @return_json, 'auto', @status)
    # render json: @return_json
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
    render json: @return_json
  end

  def error_builder(code, msg = nil)
    @status = false
    @return_json = {'FLAG' => 'failure', 'CODE' => code, 'MSG' => msg.nil? ? I18n.t("standard_interface.error.#{code}") : I18n.t("standard_interface.error.#{code}") + ':' + msg }.to_json
    # @return_json
    render json: @return_json
  end

end
