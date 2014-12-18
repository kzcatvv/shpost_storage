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

  validates_presence_of :specification_id, :actual_amount, :virtual_amount

  scope :expiration_date_first, ->{order(:expiration_date )}
  scope :prior, ->{ includes(:shelf).order("shelves.priority_level ASC, virtual_amount DESC")}
  scope :available, -> { where("1 = 1")}
  scope :normal, -> { includes(:shelf).where("shelves.shelf_type != 'broken'")}
  scope :broken, -> { includes(:shelf).where("shelves.shelf_type = 'broken'")}
  

  def self.purchase_stock_in(purchase, operation_user = nil)
    purchase.purchase_details.each do |x|
      x.purchase_arrivals.each do |arrival|
      # while x.waiting_amount > 0
        while arrival.waiting_amount > 0
          stock = Stock.get_available_stock_in_storage(x.specification, x.supplier, purchase.business, arrival.batch_no, purchase.storage, false)
          
          stock_in_amount = stock.stock_in_amount(arrival.waiting_amount)
          stock.expiration_date = arrival.expiration_date

          stock.save

          purchase.stock_logs.create(stock: stock, user: operation_user, operation: StockLog::OPERATION[:purchase_stock_in], status: StockLog::STATUS[:waiting], amount: stock_in_amount, operation_type: StockLog::OPERATION_TYPE[:in])
        end
      end
    end
  end

  def self.order_return_stock_in(order_return, operation_user = nil)
    order_return.order_return_details.each do |x|
      stock = get_available_stock_in_storage(x.order_detail.specification, x.order_detail.supplier, x.order.business, nil, x.order.storage, x.broken?)

      stock_in_amount = stock.stock_in_amount(x.order_detail.amount)

      stock.save

      order_return.stock_logs.create(stock: stock, user: operation_user, operation: StockLog::OPERATION[(x.broken?) ? :order_bad_return : :order_return], status: StockLog::STATUS[:waiting], amount: stock_in_amount, operation_type: StockLog::OPERATION_TYPE[:in])
    end
  end

  def self.broken_stock_change(stock, broken_shelf, amount, operation_user = nil)
    broken_stock = get_available_stock_in_shelf(stock.specification, stock.supplier, stock.business, nil, broken_shelf, true)

    stock.stock_out_amount(amount)
    stock.check_out_amount(amount)
    stock.save

    broken_stock.stock_in_amount(amount)
    broken_stock.check_in_amount(amount)
    broken_stock.save

    StockLog.create(user: operation_user, stock: stock, operation:  StockLog::OPERATION[:move_to_bad], status: StockLog::STATUS[:checked], operation_type: StockLog::OPERATION_TYPE[:out], amount: amount, checked_at: Time.now)

    StockLog.create(user: operation_user, stock: broken_stock, operation:  StockLog::OPERATION[:bad_stock_in], status: StockLog::STATUS[:checked], operation_type: StockLog::OPERATION_TYPE[:in], amount: amount, checked_at: Time.now)
  end

  def self.manual_stock_stock_out(manual_stock, operation_user = nil)
    # if manual_stock.
    if Stock.is_enough_stock?(manual_stock)
      Stock.stock_out(manual_stock, operation_user)
    end
  end

  def self.order_stock_out(keyclientorder, operation_user = nil)
    if Stock.is_enough_stock?(keyclientorder)
      Stock.stock_out(keyclientorder, operation_user)
    end
  end


  def self.stock_out(order, operation_user = nil)
    order.waiting_amounts.each do |x, amount|
      if amount > 0
        stocks_in_storage = Stock.find_stocks_in_storage(Specification.find(x[0]), x[1].blank? ? nil : Supplier.find(x[1]), Business.find(x[2]), order.storage).to_ary

        stocks_in_storage.each do |stock|
          out_amount = stock.stock_out_amount(amount)

          amount -= out_amount

          stock.save

          order.stock_logs.create(stock: stock, user: operation_user, operation: order.stock_log_operation, status: StockLog::STATUS[:waiting], amount: out_amount, operation_type: StockLog::OPERATION_TYPE[:out])

          if amount <= 0
            break
          end
        end
      end 
    end
  end

  def self.is_enough_stock?(order)
    order.waiting_amounts.each do |x, amount|
      total_amount = total_stock_in_storage(Specification.find(x[0]), x[1].blank? ? nil : Supplier.find(x[1]), Business.find(x[2]), order.storage)

      if total_amount < amount
        return false
      end
    end
    return true
  end

  def self.get_available_stock_in_storage(specification, supplier, business, batch_no, storage, is_broken = false)
    #find same stock to use
    stocks_in_storage_with_batch_no = find_stocks_in_storage(specification, supplier, business, storage, is_broken).with_batch_no(batch_no)
    stocks_in_storage_with_batch_no.each do |stock|
      return stock if stock.shelf.is_available?
    end

    #find same stock without batch no to get shelf
    stocks_in_storage_without_batch_no = find_stocks_in_storage(specification, supplier, business, storage, is_broken).without_batch_no(batch_no)

    stocks_in_storage_without_batch_no.each do |stock|
      if stock.shelf.is_available?
        available_stock = create(specification: specification, business: business, supplier: supplier, shelf: stock.shelf, batch_no: batch_no, actual_amount: 0, virtual_amount: 0)
        return available_stock
      end
    end

    # find shelf empty in prior
    shelf = Shelf.get_neighbor_shelf stocks_in_storage_with_batch_no
    shelf ||= Shelf.get_neighbor_shelf stocks_in_storage_without_batch_no
    shelf ||= Shelf.get_empty_shelf(storage, is_broken)
    shelf ||= Shelf.get_default_shelf(storage, is_broken)

    create(specification: specification, business: business, supplier: supplier, shelf: shelf, batch_no: batch_no, actual_amount: 0, virtual_amount: 0)
  end

  def self.get_available_stock_in_shelf(specification, supplier, business, batch_no, shelf, is_broken = false)
    stocks_in_storage_with_batch_no = find_stocks_in_shelf(specification, supplier, business, shelf, is_broken).with_batch_no(batch_no)

    stocks_in_storage_with_batch_no.each do |stock|
      return stock if stock.shelf.is_available?
    end

    create(specification: specification, business: business, supplier: supplier, shelf: shelf, batch_no: batch_no, actual_amount: 0, virtual_amount: 0)
  end

  def self.find_stock_in_shelf_with_batch_no(specification, supplier, business, batch_no, shelf)
    in_shelf(shelf).find_stocks(specification, supplier, business).with_batch_no(batch_no).first
  end

  def self.find_stock_in_storage(specification, supplier, business, storage)
    in_storage(storage).find_stocks(specification, supplier, business).available.prior.first
  end

  def self.find_stocks_in_storage(specification, supplier, business, storage, is_broken = false)
    in_storage(storage).find_stocks(specification, supplier, business, is_broken).expiration_date_first.available.prior
  end

  def self.find_stocks_in_shelf(specification, supplier, business, shelf, is_broken = false)
    in_shelf(shelf).find_stocks(specification, supplier, business, is_broken).expiration_date_first.available.prior
  end

  def self.total_stock_in_unit(specification, supplier, business, unit)
    in_unit(unit).find_stocks(specification, supplier, business).sum_virtual_amount
  end

  def self.total_stock_in_storage(specification, supplier, business, storage)
    in_storage(storage).find_stocks(specification, supplier, business).sum_virtual_amount
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

  def stock_in_amount(amount)
    in_amount = free_amount(amount)
    self.virtual_amount += in_amount
    in_amount
  end

  def stock_out_amount(amount)
    if self.available_amount > amount
      self.virtual_amount -= amount
      return amount
    else
      out_amount = self.available_amount
      self.virtual_amount -= out_amount
      return out_amount
    end
  end

  def check_in_amount(amount)
    self.actual_amount += amount
  end

  def check_out_amount(amount)
    self.actual_amount -= amount
  end

  def check_reset_amount(amount)
    self.actual_amount = amount
  end

  def free_amount(amount)
    amount
  end

  def available_amount
    if self.actual_amount <= self.virtual_amount
      return self.actual_amount
    else
      return self.virtual_amount
    end
  end

  def self.warning_stocks(storage)
    select('specification_id as spec_id, business_id as b_id, supplier_id as s_id, sum(virtual_amount) as virtual_amount').joins(:storage).in_storage(storage).normal.group(:specification_id, :business_id, :supplier_id).having('sum(virtual_amount) < (?)', Relationship.select(:warning_amt).where('specification_id = spec_id and business_id = b_id and supplier_id = s_id'))
  end

  protected
  def self.sum_virtual_amount
    sum(:virtual_amount)
  end

  def self.find_stocks(specification, supplier, business, is_broken = false)
    conditions = where(specification: specification, business: business).where('virtual_amount > 0')

    if ! is_broken
      conditions = conditions.normal
    else
      conditions = conditions.broken
    end

    if ! supplier.nil?
      conditions = conditions.where(supplier: supplier)
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
end
