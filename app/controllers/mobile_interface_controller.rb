class MobileInterfaceController < ApplicationController
  skip_before_filter :authenticate_user!
  before_action :verify_params
  before_action :verify_sign
  before_action :verify_user, except: [:login, :logout]
  # around_action :save_mobile_log
  skip_before_filter :verify_authenticity_token 
  #load_and_authorize_resource

  def login
    username = @context_hash['username']
    password = @context_hash['password']
    @user = User.find_by(username: username)
    if @user.blank? || ! @user.valid_password?(password)
      return error_builder('0005') 
    end

    return error_builder('0009') if ! @user.sorter?(@storage)

    Mobile.where(user_id: @user).update_all(user_id: nil)

    @mobile.update(version: @version, user: @user)

    success_builder({id: @user.id, time: Time.now.strftime('%Y%m%d %H:%M:%S'), version: I18n.t("mobile_interface.version"), url: "http://#{request.host}:#{request.port}#{I18n.t('mobile_interface.url')}", update: I18n.t("mobile_interface.update"), shelfcode: Sequence.generate_initial(@storage.unit, Shelf)})
  end

  def shelves
    all = @context_hash['all']

    if ! all.blank? && all.eql?("Y")
      shelves = Shelf.joins(:area).where(areas: {storage_id: @storage})
    else
      shelves = Shelf.joins(:area).where(areas: {storage_id: @storage}).where("shelves.updated_at > ?", Mobile.last.last_sign_in_time)

    end

    shelves_arry = []

    shelves.each do |x|
      shelves_arry << {shelf: x.shelf_code, shelf_barcode: x.barcode, type: Shelf::SHELF_TYPE[x.shelf_type.to_sym], area: x.area.name}
    end

    @mobile.update(last_sign_in_time: Time.now)

    success_builder({time: Time.now.strftime('%Y%m%d %H:%M:%S'), shelves: shelves_arry})
  end

  def logout
    username = @context_hash['username']
    # @user = User.find_by(username: username)
    # return error_builder('0005') if @user.blank?

    @mobile.update(version: @version, user: nil)
    success_builder({time: Time.now.strftime('%Y%m%d %H:%M:%S')})
  end

  def mission
    tasks = Task.where(status: Task::STATUS[:doing],user: @user)

    missions = []

    tasks.each do |x|
      missions << {mission: x.id, barcode: x.barcode, title: x.title, type: Task::OPERATE_TYPE[x.parent_type.to_s.to_sym], time: x.created_at.strftime('%Y%m%d %H:%M:%S'), mission_code: x.code}
    end

    success_builder({time: Time.now.strftime('%Y%m%d %H:%M:%S'), missions: missions })
  end

  def mission_details
    mission = @context_hash['mission']
    barcode = @context_hash['barcode']

    task = Task.find_by id: mission
    task ||= Task.find_by(barcode: barcode)
    task ||= Task.find_by(code: barcode)

    parent = task.try :parent

    return error_builder('0007') if task.blank? || task.done? || parent.blank?

    if ! task.user.blank? && ! task.user.eql?(@user)
      task = Task.create(title: task.title, task_type: task.task_type, status: Task::STATUS[:doing], parent: parent, storage: task.storage, user: @user)
    end

    products = []
    parent.stock_logs.waiting.group(:relationship_id, :shelf_id, :operation_type).sum(:amount).each do |x, y|
      relationship = Relationship.find x[0]
      shelf = Shelf.find x[1]
      stock_logs = parent.stock_logs.where(relationship_id: x[0], shelf_id: x[1], operation_type: x[2])
      batch_no = stock_logs.reject{|stock_log| stock_log.batch_no.blank?}.map{|stock_log| stock_log.batch_no}.join("_")
      sn = stock_logs.reject{|stock_log| stock_log.sn.blank?}.map{|stock_log| stock_log.batch_no}.join(Stock::SN_SPLIT)

      products << {sku: relationship.barcode, product: relationship.specification.full_title, business: relationship.business.name, supplier: relationship.supplier.name, batch: batch_no, product_barcode: relationship.try(:barcode), product_sixnine: relationship.specification.sixnine_code, product_sn: sn.blank? ? nil : sn.try(:split, Stock::SN_SPLIT), amount: y, scan: relationship.piece_to_piece ? "Y" : "N", shelf: shelf.shelf_code, shelf_barcode: shelf.barcode, type: x[2] }
    end

    success_builder({time: Time.now.strftime('%Y%m%d %H:%M:%S'), mission: task.id, barcode: task.barcode, title: task.title, type: task.task_type, mission_time: task.created_at.strftime('%Y%m%d %H:%M:%S'), products: products})
  end

  def mission_upload
    Task.transaction do
      mission = @context_hash['mission']
      products = @context_hash['products']

      task = nil

      code = nil

      if mission.eql? 'move'
        move_stock = MoveStock.create!(unit: @unit, status: MoveStock::STATUS[:opened], name: "#{Time.now.strftime('%Y%m%d%H%M%S')}移库单", storage: @storage)

        task = Task.save_task(move_stock, @storage, @user)

        stock = nil
        shelf = nil
        amount = nil

        products.each do |x|
          if ! x['stock'].blank?
            stock = Stock.find(x['stock'])

            if stock.blank?
              code = "0010"
              next
            end

            amount = x['amount'].to_i
          else
            shelf = Shelf.find_by(barcode: x['shelf'])

            if shelf.blank?
              code = "0010"
              next
            end
          end
        end

        Stock.move_stock_change(stock, shelf, amount, @user, false)

      else
        task = Task.find mission
      

        parent = task.try :parent

        error_builder('0007') if task.blank? || task.done? || parent.blank?


        new_stock_logs = []

        products.each do |x|
          if x['sku'].blank? || x['amount'].blank? || x['type'].blank? || x['shelf'].blank?
            code = "0010"
            next
          end

          relationship = Relationship.find_by barcode: x['sku']

          if relationship.blank?
            code = "0010"
            next
          end

          shelf = Shelf.find_by(barcode: x['shelf'])

          if shelf.blank?
            code = "0010"
            next
          end

          amount = x['amount'].to_i
          
          type = x['type']
          sn = x['sn']

          stock_logs = parent.stock_logs.waiting.where(relationship: relationship, operation_type: type, shelf: shelf)

          stock_logs ||= parent.stock_logs.joins(:shelf).where(shelves: {shelf_type: shelf.shelf_type}).waiting.where(relationship: relationship, operation_type: type)

          if stock_logs.blank? && (! type.eql? 'reset')
            code = "0010"
            next
          end

          if type.eql? 'in'
            stock_logs.each do |x|
              stock = Stock.get_available_stock_in_shelf(relationship.specification, relationship.supplier, relationship.business, x.expiration_date.blank? ? nil : x.batch_no, shelf)

              if stock_logs.last.eql? x || amount < x.amount
                in_amount = amount
              else
                in_amount = x.amount
              end

              out_stock_log = new_stock_logs.select{|sl| sl.operation_type.eql?(StockLog::OPERATION_TYPE[:out]) && sl.relationship.eql?(x.relationship) && sl.batch_no.eql?(x.batch_no)}.first

              new_stock_logs << parent.stock_logs.create!(stock: stock, user: @user, operation: x.operation, status: StockLog::STATUS[:waiting], amount: in_amount , operation_type: type, sn: sn.try(:join, Stock::SN_SPLIT), batch_no: x.batch_no, pick_in: out_stock_log)

              break if amount < x.amount

              amount -= x.amount
            end
          elsif type.eql? 'out'
            stocks = Stock.find_stocks_in_shelf(relationship.specification, relationship.supplier, relationship.business, shelf)

            stocks.each do |stock|
              next if stock.on_shelf_amount <= 0

              out_amount = stock.stock_out_amount(amount)

              amount -= out_amount

              new_stock_logs << parent.stock_logs.create!(stock: stock, user: @user, operation: stock_logs.first.operation, status: StockLog::STATUS[:waiting], amount: out_amount, operation_type: type, sn: sn.try(:join, Stock::SN_SPLIT))

              if amount <= 0
                break
              end
            end

            if amount > 0
              code = "0010"
            end
          elsif type.eql? 'reset'
            if ! stock_logs.first.blank?
              stock_logs.first.update!(user: @user, amount: amount, sn: sn.try(:join, Stock::SN_SPLIT))
            else
              stock = Stock.get_available_stock_in_shelf(relationship.specification, relationship.supplier, relationship.business, nil, shelf)

              new_stock_logs << parent.stock_logs.create!(stock: stock, user: @user, operation: StockLog::OPERATION[:inventory], status: StockLog::STATUS[:waiting], amount: amount, operation_type: StockLog::OPERATION_TYPE[:reset], sn: sn.try(:join, Stock::SN_SPLIT))
            end
          end
        end

        if ! task.task_type.eql? 'reset'
          parent.stock_logs.waiting.where.not(id: new_stock_logs).destroy_all
        else
          parent.stock_logs.waiting.where.not(id: new_stock_logs).each do |x|
            x.update!(amount: 0)
          end
        end

        parent.check!
      end
      
      task.update!(status: Task::STATUS[:done])
      
      success_builder({time: Time.now.strftime('%Y%m%d %H:%M:%S'), msg: code.blank? ? "" : I18n.t("mobile_interface.error.#{code}")})
    end
  end

  def query
    barcode = @context_hash['barcode']

    products = []

    stocks = nil

    relationship = Relationship.find_by barcode: barcode
    specification = Specification.find_by sixnine_code: barcode

    if ! relationship.blank?
      stocks = Stock.find_stocks_in_storage(relationship.specification, relationship.business, relationship.supplier, @storage, nil)
    elsif ! specification.blank?
      stocks = Stock.find_stocks_in_storage(specification, nil, nil, @storage, nil)
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
        products << {stock: stock.id, product: stock.specification.full_title, business: stock.business.name, supplier: stock.supplier.name, batch: stock.batch_no, product_barcode: stock.relationship.try(:barcode), product_sixnine: stock.specification.sixnine_code, product_sn: stock.sn.try(:split, Stock::SN_SPLIT), expiration: stock.expiration_date.try(:strftime,'%Y%m%d'), amount: stock.on_shelf_amount, shelf: stock.shelf.shelf_code, shelf_barcode: stock.shelf.barcode, type: stock.shelf.shelf_type, date: stock.updated_at.strftime('%Y%m%d %H:%M:%S') }
      end

      success_builder({time: Time.now.strftime('%Y%m%d %H:%M:%S'), products: products})
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

    @unit = @storage.unit

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
    return error_builder('0001') if ! @sign.eql?(Digest::MD5.hexdigest(@context))
  end

  def verify_user
    @user = User.find(params[:user]) if ! params[:user].blank?
    return error_builder('0005') if @user.blank?
    return error_builder('0009') if ! @user.sorter?(@storage)

    return error_builder('0006') if ! @mobile.user.eql? @user
  end

  # def save_mobile_log
  #   # if !@status.eql? false
  #     yield
  #   # end
  #   binding.pry
  #   MobileLog.created_at(request: request.url, response: @return_json, user: @user, storage: @storage, unit: @unit, mobile: @mobile, status: @status, operate_type: 'auto')
  #   # InterfaceInfo.receive_info(request.url, @return_json, 'auto', @status)
  #   # render json: @return_json
  # end

  def success_builder(info = nil)
    @status = true
    success = {flag: 'success'}
    if info.nil?
      @return_json = success
    else
      @return_json = success.merge info
    end
    # @return_json

    MobileLog.create(request_ip: request.ip, request: request.url, response: @return_json.to_json, user: @user, storage: @storage, unit: @unit, mobile: @mobile, status: 'success', operate_type: request.method, request_params: request.params.to_json)

    render json: @return_json
  end

  def error_builder(code, msg = nil)
    @status = false
    @return_json = {flag: 'failure', code: code, msg: msg.nil? ? I18n.t("mobile_interface.error.#{code}") :  msg }.to_json

    MobileLog.create(request_ip: request.ip, request: request.url, response: @return_json.to_json, user: @user, storage: @storage, unit: @unit, mobile: @mobile, status: 'failure', operate_type: request.method, request_params: request.params.to_json)
    # @return_json
    render json: @return_json
  end

end
