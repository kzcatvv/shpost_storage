class Stock < ActiveRecord::Base
  belongs_to :specification
  belongs_to :shelf
  belongs_to :business
  belongs_to :supplier
  # belongs_to :storage
  has_one :area, through: :shelf
  has_one :storage, through: :shelf
  has_one :unit, through: :shelf
  has_many :stock_logs
  belongs_to :relationship

  before_save :set_relationship
  after_touch :clean_orphan_stocks
  after_update :clean_orphan_stocks

  validates_presence_of :specification_id, :actual_amount

  scope :expiration_date_first, ->{order(:expiration_date )}
  scope :prior, ->{ includes(:shelf).order("shelves.priority_level ASC, actual_amount DESC")}
  scope :available, -> { where("1 = 1")}
  scope :normal, -> { includes(:shelf).where("shelves.shelf_type = 'normal' or shelves.shelf_type is null")}
  scope :broken, -> { includes(:shelf).where("shelves.shelf_type = 'broken'")}
  scope :not_empty, -> {where('actual_amount > 0')}
  scope :empty, -> {where('actual_amount = 0')}

  SN_SPLIT = "."

  def self.purchase_stock_in(purchase, operation_user = nil)
    purchase.purchase_arrivals.each do |arrival|
      # while x.waiting_amount > 0
      next if arrival.purchase_detail.specification.blank?

      while arrival.waiting_amount > 0
        is_broken=false if arrival.purchase_detail.defective.eql?"0"
        is_broken=true if arrival.purchase_detail.defective.eql?"1"
        
        stock = Stock.get_available_stock_in_storage(arrival.purchase_detail.specification, arrival.purchase_detail.supplier, purchase.business, arrival.expiration_date.blank? ? nil : arrival.batch_no, purchase.storage, is_broken)
        
        stock_in_amount = stock.stock_in_amount(arrival.waiting_amount)

        purchase.stock_logs.create(stock: stock, user: operation_user, operation: StockLog::OPERATION[:purchase_stock_in], status: StockLog::STATUS[:waiting], amount: stock_in_amount, operation_type: StockLog::OPERATION_TYPE[:in], batch_no: arrival.batch_no)
      
        if !arrival.expiration_date.blank?
          stock.update(expiration_date: arrival.expiration_date)
        end
      end
    end

    Task.save_task(purchase, purchase.storage, nil)
  end

  def self.order_return_stock_in(order_return, operation_user = nil)
    order_return.order_return_details.each do |x|
      stock = get_available_stock_in_storage(x.order_detail.specification, x.order_detail.supplier, x.order.business, nil, x.order.storage, x.broken?)

      stock_in_amount = stock.stock_in_amount(x.order_detail.amount)

      # stock.save

      order_return.stock_logs.create(stock: stock, user: operation_user, operation: StockLog::OPERATION[(x.broken?) ? :order_bad_return : :order_return], status: StockLog::STATUS[:waiting], amount: stock_in_amount, operation_type: StockLog::OPERATION_TYPE[:in])
    end
  end

  # def self.broken_stock_change(stock, broken_shelf, amount, operation_user = nil)
  #   broken_stock = get_available_stock_in_shelf(stock.specification, stock.supplier, stock.business, nil, broken_shelf)

  #   amount = stock.stock_out_amount(amount)
  #   stock.check_out_amount(amount)

  #   # broken_stock.stock_in_amount(amount)
  #   broken_stock.check_in_amount(amount)

  #   StockLog.create(user: operation_user, stock: stock, operation:  StockLog::OPERATION[:move_to_bad], status: StockLog::STATUS[:checked], operation_type: StockLog::OPERATION_TYPE[:out], amount: amount, checked_at: Time.now)

  #   StockLog.create(user: operation_user, stock: broken_stock, operation:  StockLog::OPERATION[:bad_stock_in], status: StockLog::STATUS[:checked], operation_type: StockLog::OPERATION_TYPE[:in], amount: amount, checked_at: Time.now)
  # end

  def self.move_stock_change(stock, move_shelf, amount, operation_user = nil, is_broken = false)
    move_stock = MoveStock.create!(unit: stock.unit, status: MoveStock::STATUS[:closed], name: "#{Time.now.strftime('%Y%m%d%H%M%S')}移库单", storage: stock.storage)


    amount = stock.stock_out_amount(amount)

    if amount <= 0
      return
    end

    in_stock = get_available_stock_in_shelf(stock.specification, stock.supplier, stock.business, stock.batch_no, move_shelf)

    out_stock_log = StockLog.create(user: operation_user, stock: stock, operation: is_broken ? StockLog::OPERATION[:move_to_bad] : StockLog::OPERATION[:move_stock_out], status: StockLog::STATUS[:waiting], operation_type: StockLog::OPERATION_TYPE[:out], amount: amount, checked_at: Time.now, batch_no: stock.batch_no, parent: move_stock)

    # stock.check_out_amount(amount)

    in_stock_log = StockLog.create(user: operation_user, stock: in_stock, operation: is_broken ? StockLog::OPERATION[:bad_stock_in] : StockLog::OPERATION[:move_stock_in], status: StockLog::STATUS[:waiting], operation_type: StockLog::OPERATION_TYPE[:in], amount: amount, checked_at: Time.now, batch_no: in_stock.batch_no, pick_out: out_stock_log.reload, parent: move_stock)

    # in_stock.check_in_amount(amount)

    move_stock
  end

  def self.manual_stock_stock_out(manual_stock, operation_user = nil)
    # if manual_stock.
    if Stock.is_enough_stock?(manual_stock)
      Stock.stock_out(manual_stock, operation_user)
    end
    
    Task.save_task(manual_stock,manual_stock.storage,nil)
  end

  def self.order_stock_out(keyclientorder, operation_user = nil)
    if Stock.is_enough_stock?(keyclientorder)
      Stock.stock_out(keyclientorder, operation_user)
    end
    
    Task.save_task(keyclientorder,keyclientorder.storage,nil)
  end

  # def self.order_pick_stock_out(keyclientorder, operation_user = nil)
  #   if Stock.is_enough_stock?(keyclientorder)
  #     Stock.pick_stock_out(keyclientorder, operation_user)
  #   end
  # end


  def self.stock_out(order, operation_user = nil)
    # binding.pry
    order.waiting_amounts.each do |x, amount|
      if amount > 0
        if !x[3].blank?
          is_broken=true if x[3].eql?"1"
          is_broken=false if x[3].eql?"0"
        else
          is_broken=nil
        end
        stocks_in_storage = Stock.find_stocks_in_storage(Specification.find(x[0]), x[1].blank? ? nil : Supplier.find(x[1]), Business.find(x[2]), order.storage,is_broken).to_ary

        stocks_in_storage.each do |stock|
          next if stock.on_shelf_amount <= 0
          
          out_amount = stock.stock_out_amount(amount)

          amount -= out_amount

          # stock.save

          order.stock_logs.create(stock: stock, user: operation_user, operation: order.stock_log_operation, status: StockLog::STATUS[:waiting], amount: out_amount, operation_type: StockLog::OPERATION_TYPE[:out])

          if amount <= 0
            break
          end
        end
      end 
    end
  end

  def self.pick_stock_out(order,cur_storage, operation_user = nil)
    i=0
    order.pick_waiting_amounts.each do |x, amount|
      if amount > 0
        stocks_in_shelf_type = Stock.find_stocks_in_shelf_type(Specification.find(x[0]), x[1].blank? ? nil : Supplier.find(x[1]), Business.find(x[2]), "pick", cur_storage,false)
        if stocks_in_shelf_type.count > 0
          in_stock = stocks_in_shelf_type.first
        else
          shelves = Shelf.get_empty_pick_shelf(order.storage)
          if shelves.count > 0
            shelf = shelves.first
            in_stock = Stock.create(specification_id: x[0], business_id: x[2], supplier_id: x[1], shelf: shelf, actual_amount: 0)
          else
            pick_shelves = Shelf.get_pick_shelf(order.storage).to_ary
            shelf = Shelf.where(id: pick_shelves[i]).first
            if i == pick_shelves.size - 1
               i = 0
            else
               i += 1
            end
            in_stock = Stock.create(specification_id: x[0], business_id: x[2], supplier_id: x[1], shelf: shelf, actual_amount: 0)
          end

        end

        stocks_in_storage = Stock.find_stocks_in_storage(Specification.find(x[0]), x[1].blank? ? nil : Supplier.find(x[1]), Business.find(x[2]), order.storage,is_broken=false).to_ary

        stocks_in_storage.each do |stock|
          out_amount = stock.stock_out_amount(amount)

          amount -= out_amount

          # stock.save

          outpick_sl = order.stock_logs.create(stock: stock, user: operation_user, operation: order.stock_log_operation, status: StockLog::STATUS[:waiting], amount: out_amount, operation_type: StockLog::OPERATION_TYPE[:out])          
          inpick_sl = order.stock_logs.create(stock: in_stock, user: operation_user, operation: order.stock_log_operation, status: StockLog::STATUS[:waiting], amount: out_amount, operation_type: StockLog::OPERATION_TYPE[:in]) 
          inpick_sl.pick_out = outpick_sl
          inpick_sl.save

          if amount <= 0
            break
          end
        end
      end 
    end
  end

  def self.is_enough_stock?(order)
    order.waiting_amounts.each do |x, amount|
      if !x[3].blank?
        is_broken=true if x[3].eql?"1"
        is_broken=false if x[3].eql?"0"
      else
        is_broken=nil
      end
      total_amount = total_stock_in_storage(Specification.find(x[0]), x[1].blank? ? nil : Supplier.find(x[1]), Business.find(x[2]), order.storage,is_broken)

      if total_amount < amount
        return false
      end
    end
    return true
  end

  def self.get_available_stock_in_storage(specification, supplier, business, batch_no, storage, is_broken)
    #find same stock to use
    stocks_in_storage_with_batch_no = find_stocks_in_storage(specification, supplier, business, storage, is_broken).with_batch_no(batch_no)
    stocks_in_storage_with_batch_no.each do |stock|
      return stock if stock.shelf.is_available?
    end

    #find same stock without batch no to get shelf
    stocks_in_storage_without_batch_no = find_stocks_in_storage(specification, supplier, business, storage, is_broken).without_batch_no(batch_no)

    stocks_in_storage_without_batch_no.each do |stock|
      if stock.shelf.is_available?
        available_stock =  Stock.create(specification: specification, business: business, supplier: supplier, shelf: stock.shelf, batch_no: batch_no, actual_amount: 0)
        return available_stock
      end
    end

    # find shelf empty in prior
    shelf = Shelf.get_neighbor_shelf stocks_in_storage_with_batch_no
    shelf ||= Shelf.get_neighbor_shelf stocks_in_storage_without_batch_no
    shelf ||= Shelf.get_empty_shelf(storage, is_broken)
    shelf ||= Shelf.get_default_shelf(storage, is_broken)

    Stock.create(specification: specification, business: business, supplier: supplier, shelf: shelf, batch_no: batch_no, actual_amount: 0)
  end

  def self.get_available_stock_in_shelf(specification, supplier, business, batch_no, shelf)
    stocks_in_storage_with_batch_no = find_stocks_in_shelf(specification, supplier, business, shelf).with_batch_no(batch_no)

    stocks_in_storage_with_batch_no.each do |stock|
      return stock if stock.shelf.is_available?
    end

    Stock.create(specification: specification, business: business, supplier: supplier, shelf: shelf, batch_no: batch_no, actual_amount: 0)
  end

  def self.find_stock_in_shelf_with_batch_no(specification, supplier, business, batch_no, shelf)
    in_shelf(shelf).find_stocks(specification, supplier, business, false).with_batch_no(batch_no).first
  end

  def self.find_stock_in_storage(specification, supplier, business, storage)
    in_storage(storage).find_stocks(specification, supplier, business, false).available.prior.first
  end

  def self.find_stocks_in_storage(specification, supplier, business, storage, is_broken)
    in_storage(storage).find_stocks(specification, supplier, business, is_broken).expiration_date_first.available.prior
  end

  def self.find_stocks_in_shelf(specification, supplier, business, shelf)
    in_shelf(shelf).find_stocks(specification, supplier, business, false).expiration_date_first.available.prior
  end

  def self.find_stocks_in_shelf_type(specification, supplier, business, shelf_type,storage, is_broken = false)
    in_storage(storage).in_shelf_type(shelf_type).find_stocks(specification, supplier, business, is_broken).expiration_date_first.available.prior
  end

  def self.total_stock_in_unit(specification, supplier, business, unit)
    in_unit(unit).find_stocks(specification, supplier, business, false).sum(:actual_amount) 
    # + StockLog.virtual_amount_in_unit(specification, supplier, business, unit)
  end

  def self.total_stock_in_storage(specification, supplier, business, storage, is_broken)
    in_storage(storage).find_stocks(specification, supplier, business, is_broken).sum(:actual_amount)
     # +  StockLog.virtual_amount_in_storage(specification, supplier, business, storage)
  end

  def self.total_stock_in_shelf(specification, supplier, business, shelf)
    in_shelf(shelf).find_stocks(specification, supplier, business, false).sum(:actual_amount) 
    # + StockLog.virtual_amount_in_unit(specification, supplier, business, unit)
  end

  def find_same_stocklog(keyclientorder)
    stocklogs = self.stock_logs.where(status: "waiting")
    stocklogs.each do |stocklog|
      detail = stocklog.order_details.first
      if detail.blank?
        # skip the stocklog of purchase or manual_stock 
        next
      elsif detail.order.keyclientorder.id == keyclientorder.id
        return stocklog
      end
    end
    return nil
  end

  def virtual_amount
    actual_amount + in_amount - out_amount
  end

  def in_amount
    stock_logs.waiting.operation_in.sum(:amount)
  end

  def out_amount
    stock_logs.waiting.operation_out.sum(:amount)
  end

  def on_shelf_amount
    actual_amount - out_amount
  end

  def free_amount(amount)
    amount
  end

  def stock_in_amount(amount)
    free_amount(amount)
    # self.virtual_amount += in_amount
    # in_amount
  end

  def stock_out_amount(amount)
    if on_shelf_amount >= amount
      # virtual_amount -= amount
      return amount
    else
      # out_amount = on_shelf_amount
      # self.virtual_amount -= out_amount
      return on_shelf_amount
    end
  end

  def check_in_amount(amount)
    self.actual_amount += amount
    self.save
  end

  def check_out_amount(amount)
    self.actual_amount -= amount
    self.save
  end

  def check_reset_amount(amount)
    self.actual_amount = amount
    self.save
  end

  def self.warning_stocks(storage)
    in_storage(storage).normal.group(:relationship_id).having('sum(actual_amount) < (?)', Relationship.select(:warning_amt).where("relationships.id = stocks.relationship_id")).sum(:actual_amount)
  end

  def update_sn(sn, type)
    return if sn.blank?

    if type.eql? StockLog::OPERATION_TYPE[:in]
      if ! self.sn.blank?
         self.update(sn: (self.sn.split(Stock::SN_SPLIT) + sn.split(Stock::SN_SPLIT)).uniq.join(Stock::SN_SPLIT))
      else
        self.update(sn: sn)
      end
    elsif type.eql? StockLog::OPERATION_TYPE[:out]
      if ! self.sn.blank?
        self.update(sn: (self.sn.split(Stock::SN_SPLIT) - sn.split(Stock::SN_SPLIT)).join(Stock::SN_SPLIT))
      end
    elsif type.eql? StockLog::OPERATION_TYPE[:reset]
      self.update(sn: sn)
    end
  end

  protected
  def self.sum_virtual_amount
    sum(:virtual_amount)
  end

  def self.find_stocks(specification, supplier, business, is_broken)
    conditions = not_empty

    if ! specification.blank?
      conditions = conditions.where(specification: specification)
    end

    if ! business.blank?
      conditions = conditions.where(business: business)
    end

    if ! supplier.blank?
      conditions = conditions.where(supplier: supplier)
    end

    if ! is_broken.nil?
      if ! is_broken
        conditions = conditions.normal
      else
        conditions = conditions.broken
      end
    end

    return conditions
  end


  def self.with_batch_no(batch_no)
    where(batch_no: batch_no)
  end

  def self.without_batch_no(batch_no)
    where(["batch_no != ?", batch_no])
  end

  def self.in_unit(unit)
    includes(:unit).where('units.id' => unit)
  end

  def self.in_storage(storage)
    includes(:storage).where('storages.id' => storage)
  end

  def self.in_shelf(shelf)
    includes(:shelf).where('shelves.id' => shelf)
  end

  def self.in_shelf_type(shelf_type)
    includes(:shelf).where('shelves.shelf_type' => shelf_type)
  end

  private
  def clean_orphan_stocks
    if self.actual_amount.zero? && self.stock_logs.waiting.blank?
      self.destroy
    end
  end

  def set_relationship
    self.relationship = Relationship.find_by(specification_id: specification, business_id: business, supplier_id: supplier)
  end
end
