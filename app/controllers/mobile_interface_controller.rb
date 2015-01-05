class MobileInterfaceController < ApplicationController
  skip_before_filter :authenticate_user!
  before_action :verify_params
  before_action :verify_sign
  before_action :verify_user, except: [:login]
  around_action :interface_return
  #load_and_authorize_resource

  def login
    username = @context_hash['username']
    password = @context_hash['password']
    user = find_by(username: username)
    error_builder('0005') if user.blank? || !user.valid_password? password

    mobile.update(version: @version, user: user, last_sign_in_time: Time.now)
    success_builder({id: user.id, time: Time.now, version: I18n.t "mobile_interface.version", url: I18n.t "mobile_interface.url", update: I18n.t "mobile_interface.update"})
  end

  def logout
    username = @context_hash['username']
    user = find_by(username: username)
    error_builder('0005') if user.blank?

    mobile.update(version: @version, user: nil)
    success_builder({time: Time.now})
  end

  def mission
    tasks = Task.where(user: @user)

    missions = []

    tasks.each do |x|
      missions << {mission: x.id, barcode: x.barcode, title: x.title, type: x.type, time: x.created_at}
    end

    success_builder({time: Time.now, missions: miassions })
  end

  def mission_details
    mission = @context_hash['mission']
    barcode = @context_hash['barcode']

    task = Task.find mission
    task ||= Task.find_by(barcode: barcode)
    task ||= Task.find_by(code: barcode)

    error_builder('0007') if task.blank?

    products = []
    task.parent.stock_logs.each do |x|
      products << {product: x.specification.full_title, business: x.business.name, supplier: x.supplier.name, batch: x.batch_no, product_barcode: x.specification.product_sexnine: x.specification.sixnie_code, product_sn: [], amount: x.amount, scan: x.specification.piece_to_piece, shelf: x.shelf.shelf_code, shelf_barcode: x.shelf.barcode, type: x.operation_type }
    end

    success_builder({time: Time.now, mission: task.id, barcode: task.barcode, title: task.title, type: task.type, mission_time: task.created_at, products: products)
  end

  # def order_enter
  #   order_id = @context_hash['ORDER_ID']
  #   return error_builder('0005', '订单号为空') if order_id.blank?
  #   trans_sn = @context_hash['TRANS_SN']
  #   return error_builder('0005', '交易流水号为空') if trans_sn.blank?
  #   cust_name = @context_hash['CUST_NAME']
  #   return error_builder('0005', '收件人姓名为空') if cust_name.blank?
  #   addr = @context_hash['ADDR']
  #   return error_builder('0005', '收货人地址为空') if addr.blank?

  #   order_details = @context_hash['ORDER_DETAILS']
  #   return error_builder('0005', '商品列表为空') if order_details.blank?

  #   order = StandardInterface.order_enter(@context_hash, @business, @unit, @storage)
  #   if !order.blank?
  #     if order.is_a? Order
  #       success_builder({'ORDER_NO' => order.batch_no })
  #     else
  #       return error_builder('0006')
  #     end
  #   else
  #     return error_builder('9999')
  #   end

  # end

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

  # def orders_query
  #   type = nil
  #   order_nos = @context_hash['ORDER_NO']
  #   deliver_nos = @context_hash['DELIVER_NO']
  #   order_ids = @context_hash['ORDER_ID']
  #   trans_sns= @context_hash['TRANS_SN']
  #   ids = []
  #   order_details = []
  #   if !order_nos.blank?
  #     type = "ORDER_NO"
  #     ids = order_nos.split(',')
  #   elsif !deliver_nos.blank?
  #     type = "DELIVER_NO"
  #     ids = deliver_nos.split(',')
  #   elsif !order_ids.blank?
  #     type = "ORDER_ID"
  #     ids = order_ids.split(',')
  #   elsif !trans_sns.blank?
  #     type = "TRANS_SN"
  #     ids = trans_sns.split(',')
  #   end

  #   #orders_got = StandardInterface.orders_query(@context_hash, @business, @unit)
    
  #   ids.each do |id|

  #     context_string = "{\"" + type + "\":\"" + id.to_s + "\"}"
  #     context = ActiveSupport::JSON.decode(context_string)
  #     orders = StandardInterface.order_query(context, @business, @unit)

  #     if !orders.blank?
  #       # tracking_infos = orders.tracking_info

  #       orders.each do |order|
  #         order_detail = {}
  #         deliver_details = StandardInterface.generalise_tracking(order.tracking_info)

  #         order_detail['FLAG'] = "success"
  #         order_detail['ORDER_ID'] = id
  #         order_detail['STATUS'] = order.status
  #         order_detail['EXPS'] = order.transport_type
  #         order_detail['EXPS_NO'] = order.tracking_number
  #         order_detail['DESC'] = ""
  #         order_detail['DELIVER_DETAIL'] = deliver_details
  #         order_details << order_detail
  #       end
  #     else
  #       order_detail = {}
  #       order_detail['FLAG'] = "failure"
  #       order_detail['ORDER_ID'] = id
  #       order_detail['STATUS'] = ""
  #       order_detail['EXPS'] = ""
  #       order_detail['EXPS_NO'] = ""
  #       order_detail['DESC'] = "订单号不存在"
  #       order_detail['DELIVER_DETAIL'] = ""
  #       order_details << order_detail
  #     end
  #   end

  #   success_builder({'ORDER_DETAIL' => order_details})
  # end

  # def stock_query
  #   sku = @context_hash['QUERY_ARRAY']
  #   return error_builder('0005', '查询列表为空') if sku.blank?

  #   stock_array = StandardInterface.stock_query(@context_hash, @business, @unit)

  #   if !stock_array.blank?
  #     success_builder('STOCK_ARRAY' => stock_array)
  #   else
  #     error_builder('9999')
  #   end
  # end

  private
  def verify_params
    @format = params[:format]
    
    error_builder('0002') if !@format.eql? 'JSON'

    @storage = Storage.find_by(no: params[:storage])
    error_builder('0003') if @storage.nil?

    @mobile = Mobile.find_by(no: params[:mobile], storage: @storage)
    error_builder('0004') if @mobile.nil?

    @version = params[:version]

    @context = params[:context]

    begin
      @context_hash = ActiveSupport::JSON.decode(@context)
    rescue ActiveSupport::JSON.parse_error
      error_builder('0002')
    end
  end

  def verify_sign
    @sign = params[:sign]
    error_builder('0001') if !@sign.eql? Digest::MD5.hexdigest(@context)
  end

  def verify_user
    @user = User.find(params[:username])
    error_builder('0005') if @user.blank?

    error_builder('0006') if !@mobile.user.eql? @user
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
    success = {'flag' => 'success'}
    if info.nil?
      @return_json = success
    else
      @return_json = success.merge info
    end
    # @return_json
    render json: @return_json and return
  end

  def error_builder(code, msg = nil)
    @status = false
    @return_json = {'flag' => 'failure', 'code' => code, 'msg' => msg.nil? ? I18n.t("mobile_interface.error.#{code}") : I18n.t("mobile_interface.error.#{code}") + ':' + msg }.to_json
    # @return_json
    render json: @return_json and return
  end

end
