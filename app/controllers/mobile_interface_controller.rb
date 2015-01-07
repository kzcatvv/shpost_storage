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
      products << {product: x.specification.full_title, business: x.business.name, supplier: x.supplier.name, batch: x.batch_no, product_barcode: x.specification.barcode, product_sexnine: x.specification.sixnie_code, product_sn: stock.sn.try(:split, '.'), amount: x.amount, scan: x.specification.piece_to_piece, shelf: x.shelf.shelf_code, shelf_barcode: x.shelf.barcode, type: x.operation_type }
    end

    success_builder({time: Time.now, mission: task.id, barcode: task.barcode, title: task.title, type: task.type, mission_time: task.created_at, products: products)
  end

  # def mission_upload
  #   mission = @context_hash['mission']
  #   products = @context_hash['products']

  #   task = Task.find mission

  #   error_builder('0007') if task.blank?
  #   # task.parent.stock_logs.waiting.delete
  #   stock_logs = []
  #   products.each do |x|
  #     next if x['product'].blank? || x['amount'].blank? || x['type'].blank? || x['shelf'].blank?
  #     specification ||= Specification.find_by barcode: x['product']
  #     specification ||= Specification.find_by sexnine: x['product']
  #     amount = x['amount']
  #     shelf = Shelf.find_by(:barcode, x['shelf'])
  #     type = x['type']

  #     task.parent.details.where

  #     Stock.find_stock_in_shelf
  #     StockLog.create()
  #   end

  # end

  def query
    barcode = @context_hash['barcode']

    products = []

    stocks = nil

    specification ||= Specification.find_by barcode: barcode
    specification ||= Specification.find_by sexnine: barcode

    if ! specification.blank?
      stocks = Stock.find_stocks_in_storage(specification, nil, nil, storage, nil)
    end

    stocks ||= Stock.where('sn like ?', bar)
    
    if stocks.blank?
      shelf = Shelf.find_by barcode: barcode
      if ! shelf.blank?
        stocks ||= Stock.find_stocks_in_shelf(nil, nil, nil, shelf, nil)
      end
    end

    if ! stocks.blank?
      stocks.each do |stock|
        products << {product: specification.full_title, business: stock.business.name, supplier: stock.supplier.name, batch: stock.batch_no, product_barcode: specification.product_sexnine: specification.sixnie_code, product_sn: stock.sn.try(:split, '.'), expiration: stock.expiration, amount: stock.amount, shelf: stock.shelf.shelf_code, shelf_barcode: stock.shelf.barcode, type: stock.shelf.shelf_type, date: stock.updated_at }
      end

      success_builder({time: Time.now, products: products)
    else
      error_builder('0008')
    end
  end

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
