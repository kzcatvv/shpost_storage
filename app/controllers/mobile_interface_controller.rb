class MobileInterfaceController < ApplicationController
  skip_before_filter :authenticate_user!
  before_action :verify_params
  # before_action :verify_sign
  before_action :verify_user, except: [:login, :logout]
  around_action :interface_return
  #load_and_authorize_resource

  def login
    username = @context_hash['username']
    password = @context_hash['password']
    user = User.find_by(username: username)
    if user.blank? || !user.valid_password?(password)
      return error_builder('0005') 
    end

    @mobile.update(version: @version, user: user, last_sign_in_time: Time.now)
    success_builder({id: user.id, time: Time.now.strftime('%Y-%m-%d %H:%M:%S'), version: I18n.t("mobile_interface.version"), url: I18n.t("mobile_interface.url"), update: I18n.t("mobile_interface.update")})
  end


  def logout
    username = @context_hash['username']
    user = User.find_by(username: username)
    error_builder('0005') if user.blank?

    @mobile.update(version: @version, user: nil)
    success_builder({time: Time.now.strftime('%Y-%m-%d %H:%M:%S')})
  end

  def mission
    tasks = Task.where(user: @user)

    missions = []

    tasks.each do |x|
      missions << {mission: x.id, barcode: x.barcode, title: x.title, type: x.task_type, time: x.created_at.strftime('%Y-%m-%d %H:%M:%S')}
    end

    success_builder({time: Time.now.strftime('%Y-%m-%d %H:%M:%S'), missions: missions })
  end

  def mission_details
    mission = @context_hash['mission']
    barcode = @context_hash['barcode']

    task = Task.find_by id: mission
    task ||= Task.find_by(barcode: barcode)
    task ||= Task.find_by(code: barcode)

    return error_builder('0007') if task.blank? || task.done?

    if !task.user.blank? && !task.user.eql?(@user)
      task = Task.create(title: task.title, task_type: task.task_type, status: Task::STATUS[:doing], parent: task.parent, storage: task.storage, user: @user)
    end

    products = []
    task.parent.stock_logs.each do |x|
      products << {product: x.specification.full_title, business: x.business.name, supplier: x.supplier.name, batch: x.batch_no, product_barcode: x.relationship.barcode, product_sixnine: x.specification.sixnine_code, product_sn: stock.sn.try(:split, '.'), amount: x.amount, scan: x.specification.piece_to_piece, shelf: x.shelf.shelf_code, shelf_barcode: x.shelf.barcode, type: x.operation_type }
    end

    success_builder({time: Time.now.strftime('%Y-%m-%d %H:%M:%S'), mission: task.id, barcode: task.barcode, title: task.title, type: task.task_type, mission_time: task.created_at.strftime('%Y-%m-%d %H:%M:%S'), products: products})
  end

  def mission_upload
    mission = @context_hash['mission']
    products = @context_hash['products']

    task = Task.find mission

    error_builder('0007') if task.blank? || task.done?

    new_stock_logs = []

    products.each do |x|
      next if x['product'].blank? || x['amount'].blank? || x['type'].blank? || x['shelf'].blank?
      relationship = Relationship.find_by barcode: x['product']
      specification = Specification.find_by sixnine_code: x['product']
      amount = x['amount']
      shelf = Shelf.find_by(:barcode, x['shelf'])
      type = x['type']

      if ! relationship.blank?
        stock_log = task.parent.stock_logs.joins(:shelf).where(shelves: {shelf_type: shelf.shelf_type}).waiting.find_by(relationship: relationship, operation_type: type)
      elsif ! specification.blank?
        stock_log = task.parent.stock_logs.joins(:shelf).where(shelves: {shelf_type: shelf.shelf_type}).waiting.find_by(specification: specification, operation_type: type)
      else
        stock_log = task.parent.stock_logs.joins(:shelf).where(shelves: {shelf_type: shelf.shelf_type}).waiting.where('sn like', "%#{x['product']}%", operation_type: type).first
      end

      if type.eql? 'in'
        stock = Stock.get_available_stock_in_shelf(stock_log.specification, stock_log.supplier, stock_log.business, stock_log.batch_no, shelf)

        new_stock_logs << task.parent.stock_logs.create(stock: stock, user: @user, operation: stock_log.operation, status: StockLog::STATUS[:waiting], amount: amount, operation_type: type)
      elsif type.eql 'out'
        stocks = find_stocks_in_shelf(stock_log.specification, stock_log.supplier, stock_log.business, stock_log.batch_no, shelf)

        stocks.each do |stock|
          out_amount = stock.stock_out_amount(amount)

          amount -= out_amount

          new_stock_logs << task.parent.stock_logs.create(stock: stock, user: @user, operation: stock_log.operation, status: StockLog::STATUS[:waiting], amount: amount, operation_type: type)

          if amount <= 0
            break
          end
        end
      end
    end

    task.parent.stock_logs.waiting.where.not(id: new_stock_logs).destroy_all

    check.check!

    task.update(status: Task::STATUS[:done])
  end

  def query
    barcode = @context_hash['barcode']

    products = []

    stocks = nil

    relationship = Relationship.find_by barcode: barcode
    specification = Specification.find_by sixnine_code: barcode

    if ! relationship.blank?
      stocks = Stock.find_stocks_in_storage(relationship.specification, relationship.business, relationship.supplier, storage, nil)
    elsif ! specification.blank?
      stocks = Stock.find_stocks_in_storage(specification, nil, nil, storage, nil)
    end

    stocks = Stock.includes(:storage).where(storages:{id: @storage}).where('sn like ?', "%#{barcode}%") if stocks.blank?
    
    if stocks.blank?
      shelf = Shelf.includes(:storage).where(storages:{id: @storage}).find_by(barcode: barcode)
      if ! shelf.blank?
        stocks = Stock.find_stocks_in_shelf(nil, nil, nil, shelf)
      end
    end

    if ! stocks.blank?
      stocks.each do |stock|
        products << {product: stock.specification.full_title, business: stock.business.name, supplier: stock.supplier.name, batch: stock.batch_no, product_barcode: stock.relationship.try(:barcode), product_sixnine: stock.specification.sixnine_code, product_sn: stock.sn.try(:split, '.'), expiration: stock.expiration_date.strftime('%Y-%m-%d'), amount: stock.actual_amount, shelf: stock.shelf.shelf_code, shelf_barcode: stock.shelf.barcode, type: stock.shelf.shelf_type, date: stock.updated_at.strftime('%Y-%m-%d %H:%M:%S') }
      end

      success_builder({time: Time.now.strftime('%Y-%m-%d %H:%M:%S'), products: products})
    else
      error_builder('0008')
    end
  end

  private
  def verify_params
    @format = params[:format]
    
    
    return error_builder('0002') if ! @format.eql? 'JSON'

    @storage = Storage.find_by(no: params[:storage]) if ! params[:storage].blank?

    return error_builder('0003') if @storage.nil?

    @mobile = Mobile.find_by(no: params[:mobile], storage: @storage) if ! params[:mobile].blank?
    return error_builder('0004') if @mobile.nil?

    @version = params[:version]

    @context = params[:context]

    begin
      @context_hash = ActiveSupport::JSON.decode(@context)
    rescue ActiveSupport::JSON.parse_error
      return error_builder('0002')
    end
  end

  def verify_sign
    @sign = params[:sign]
    return error_builder('0001') if !@sign.eql? Digest::MD5.hexdigest(@context)
  end

  def verify_user
    @user = User.find(params[:user]) if !params[:user].blank?
    return error_builder('0005') if @user.blank?

    return error_builder('0006') if !@mobile.user.eql? @user
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
    render json: @return_json
  end

  def error_builder(code, msg = nil)
    @status = false
    @return_json = {'flag' => 'failure', 'code' => code, 'msg' => msg.nil? ? I18n.t("mobile_interface.error.#{code}") :  msg }.to_json
    # @return_json
    render json: @return_json
  end

end
