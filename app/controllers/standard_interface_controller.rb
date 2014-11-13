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

    relationship = StandardInterface.commodity_enter(@context_hash, @business, @unit)

    if !relationship.blank?
      render json: success_builder({'SKU' => relationship.specification.sku })
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
      deliver_details = []
      tracking_infos = ""
      if order_got.is_a? Order
        tracking_infos = order_got.tracking_info
      else
        tracking_infos = order_got.order.tracking_info
      end
      if !tracking_infos.blank?
        tracking_infos.split(/\n/).each do |info|
          deliver_detail = {}
          x = info.split('#')
          if x.size == 4
            deliver_detail['DATE'] = x[0]
            deliver_detail['LOCAL'] = x[2]
            # deliver_detail['NAME'] = x[]
            deliver_detail['DESC'] = x[1]
          elsif x.size == 2
            deliver_detail['DATE'] = x[0]
            deliver_detail['DESC'] = x[1]
          end
          deliver_details << deliver_detail
        end
      end
      if order_got.is_a? Order
        render json: success_builder({'STATUS' => order_got.status, 'EXPS' => order_got.transport_type, 'EXPS_NO' => order_got.tracking_number, 'DELIVER_DETAIL' => deliver_details})
      else
        render json: success_builder({'STATUS' => order_got.order.status, 'EXPS' => order_got.order.transport_type, 'EXPS_NO' => order_got.order.tracking_number, 'DELIVER_DETAIL' => deliver_details})
      end
    else
      render json: error_builder('9999')
    end
  end

  def stock_query
    sku = @context_hash['QUERY_ARRAY']
    return render json: error_builder('0005', '查询列表为空') if sku.blank?

    stock_array = StandardInterface.stock_query(@context_hash, @business, @unit)

    if !stock_array.blank?
      render json: success_builder('STOCK_ARRAY' => stock_array)
    else
      render json: error_builder('9999')
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
      order_got = StandardInterface.order_query(context, @business, @unit)

      deliver_details = []
      if !order_got.blank?
        tracking_infos = ""
        if order_got.is_a? Order
          tracking_infos = order_got.tracking_info
        else
          tracking_infos = order_got.order.tracking_info
        end
        if !tracking_infos.blank?
          tracking_infos.split(/\n/).each do |info|
            deliver_detail = {}
            x = info.split('#')
            if x.size == 4
              deliver_detail['DATE'] = x[0]
              deliver_detail['LOCAL'] = x[2]
              # deliver_detail['NAME'] = x[]
              deliver_detail['DESC'] = x[1]
            elsif x.size == 2
              deliver_detail['DATE'] = x[0]
              deliver_detail['DESC'] = x[1]
            end
            deliver_details << deliver_detail
          end
        end
        if order_got.is_a? Order
          order_detail['FLAG'] = "success"
          order_detail['ORDER_ID'] = id
          order_detail['STATUS'] = order_got.status
          order_detail['EXPS'] = order_got.transport_type
          order_detail['EXPS_NO'] = order_got.tracking_number
          order_detail['DESC'] = ""
          order_detail['DELIVER_DETAIL'] = deliver_details
          order_details << order_detail
        else
          order_detail['FLAG'] = "success"
          order_detail['ORDER_ID'] = id
          order_detail['STATUS'] = order_got.order.status
          order_detail['EXPS'] = order_got.order.transport_type
          order_detail['EXPS_NO'] = order_got.order.tracking_number
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
    render json: {'ORDER_DETAIL' => order_details}
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
    render json: error_builder('0001') if !@sign.eql? Digest::MD5.hexdigest(@context + @business.secret_key)
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
