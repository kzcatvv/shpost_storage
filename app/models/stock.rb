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


  def self.purchase_stock_in(purchase, operation_user = nil)
    purchase.purchase_details.each do |x|
      while x.waiting_amount > 0
        stock = Stock.get_available_stock(x.specification, x.supplier, purchase.business, x.batch_no, purchase.storage)
        
        stock_in_amount = stock.stock_in_amount(x.waiting_amount)
        stock.expiration_date = x.expiration_date

        stock.save

        x.stock_logs.create(stock: stock, user: operation_user, operation: StockLog::OPERATION[:purchase_stock_in], status: StockLog::STATUS[:waiting], parent: purchase, amount: stock_in_amount, operation_type: StockLog::OPERATION_TYPE[:in])
      end
    end
  end

  def self.order_return_stock_in(order_return)
    
  end

  def self.manual_stock_stock_out(manual_stock, operation_user = nil)
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
    sum_amount_hash = order.details.group(:specification_id, :supplier_id, :business_id, :storage_id).sum(:amount)

    sum_amount_hash.each do |x, amount|
      if amount > 0
        stocks_in_storage = Stock.find_stocks_in_storage(Specification.find(x[0]), Supplier.find(x[1]), Business.find(x[2]), Storage.find(x[3])).to_ary

        stocks_in_storage.each do |stock|
          out_amount = stock.stock_out_amount(amount)

          amount -= out_amount

          stock.save

          stock_log = StockLog.create(stock: stock, user: operation_user, operation: order.stock_log_operation, status: StockLog::STATUS[:waiting], amount: out_amount, operation_type: StockLog::OPERATION_TYPE[:out], parent: order)

          if amount <= 0
            break
          end
        end
      end 
    end
  end

  def self.is_enough_stock?(order)
    sum_amount_hash = order.details.group(:specification_id, :supplier_id, :business_id, :storage_id).sum(:amount)

    sum_amount_hash.each do |x, amount|
      total_amount = total_stock_in_storage(Specification.find(x[0]), Supplier.find(x[1]), Business.find(x[2]), Storage.find(x[3]))

      if total_amount < amount
        return false
      end
    end
    return true
  end

  def self.get_available_stock(specification, supplier, business, batch_no, storage)
    stocks_in_storage_with_batch_no = find_stocks_in_storage(specification, supplier, business, storage).with_batch_no(batch_no)
    stocks_in_storage_with_batch_no.each do |stock|
      return stock if stock.is_available?
    end

    stocks_in_storage_without_batch_no = find_stocks_in_storage(specification, supplier, business, storage).without_batch_no(batch_no)

    stocks_in_storage_without_batch_no.each do |stock|
      if stock.is_available?
        available_stock = create(specification: specification, business: business, supplier: supplier, shelf: stock.shelf, batch_no: batch_no, actual_amount: 0, virtual_amount: 0)
        return available_stock
      end
    end
    # find shelf empty in prior
    shelf = Shelf.get_neighbor_shelf stocks_in_storage_with_batch_no
    shelf ||= Shelf.get_neighbor_shelf stocks_in_storage_without_batch_no
    shelf ||= Shelf.get_empty_shelf storage
    shelf ||= Shelf.get_default_shelf storage

    create(specification: specification, business: business, supplier: supplier, shelf: shelf, batch_no: batch_no, actual_amount: 0, virtual_amount: 0)
  end

  def self.find_stock_in_shelf_with_batch_no(specification, supplier, business, batch_no, shelf)
    in_shelf(shelf).find_stock(specification, supplier, business).with_batch_no(batch_no).first
  end

  def self.find_stock_in_storage(specification, supplier, business, storage)
    in_storage(storage).find_stock(specification, supplier, business).available.prior.first
  end

  def self.find_stocks_in_storage(specification, supplier, business, storage)
    in_storage(storage).find_stock(specification, supplier, business).expiration_date_first.available.prior
  end

  def self.total_stock_in_unit(specification, supplier, business, unit)
    in_unit(unit).find_stock(specification, supplier, business).sum_virtual_amount
  end

  def self.total_stock_in_storage(specification, supplier, business, storage)
    in_storage(storage).find_stock(specification, supplier, business).sum_virtual_amount
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

  def is_available?
    true
  end

  def available_amount
    if self.actual_amount <= self.virtual_amount
      return self.actual_amount
    else
      return self.virtual_amount
    end
  end

  def self.warning_stocks(storage)
    select('specification_id as spec_id, business_id as b_id, supplier_id as s_id, sum(virtual_amount) as virtual_amount').joins(:storage,:shelf).where('storages.id' => storage,'shelves.is_bad' => 'no').group(:specification_id, :business_id, :supplier_id).having('sum(virtual_amount) < (?)', Relationship.select(:warning_amt).where('specification_id = spec_id and business_id = b_id and supplier_id = s_id'))
  end

  protected
  def self.sum_virtual_amount
    sum(:virtual_amount)
  end

  def self.find_stock(specification, supplier, business)
    conditions = where(specification: specification, business: business).includes(:shelf).where("shelves.is_bad='no'")

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

  # def self.get_product_hash(order,detail,product_hash)
  #   product = [order.business,detail.specification,detail.supplier]
  #   if product_hash.has_key?(product)
  #       product_hash[product][0] = product_hash[product][0]+detail.amount
  #       product_hash[product][1]<<detail
  #   else
  #       product_hash[product] = [detail.amount, [detail]]
  #   end
  #   return product_hash
  # end

  # def self.stock_out(product_hash,current_storage,current_user)
  #   sklogs = []
  #   product_hash.each do |x|
  #     product = x[0]
  #     amount = x[1][0]
  #     details = x[1][1]
  #     if details.first.stock_logs.blank?
  #       outstocks = Stock.find_stocks_in_storage(product[1], product[2], product[0], current_storage).to_ary
  #       outstocks.each do |outstock|
  #         available_amount = outstock.available_amount
  #         if available_amount == 0
  #           next
  #         elsif available_amount >= amount
  #           outstock.update_attribute(:virtual_amount , outstock.virtual_amount - amount)
  #           outstock.save
  #           # 20141029 merge the same stocklog
  #           if details.first.is_a? ManualStockDetail
  #             stocklog = nil
  #           else
  #             stocklog = outstock.find_same_stocklog(details.first.order.keyclientorder)
  #           end
  #           if stocklog.blank?
  #             stocklog = StockLog.create(stock: outstock, user: current_user, operation: StockLog::OPERATION[:b2c_stock_out], status: StockLog::STATUS[:waiting], amount: amount, operation_type: StockLog::OPERATION_TYPE[:out])
  #           else
  #             stocklog.update_attribute(:amount, stocklog.amount + amount)
  #           end
  #           details.each do |x|
  #             x.stock_logs << stocklog
  #           end
  #           sklogs << stocklog
  #           break
  #         else
  #           amount = amount - available_amount
  #           outstock.update_attribute(:virtual_amount , outstock.virtual_amount - available_amount)
  #           outstock.save
  #           # 20141029 merge the same stocklog
  #           if details.first.is_a? ManualStockDetail
  #             stocklog = nil
  #           else
  #             stocklog = outstock.find_same_stocklog(details.first.order.keyclientorder)
  #           end
  #           if stocklog.blank?
  #             stocklog = StockLog.create(stock: outstock, user: current_user, operation: StockLog::OPERATION[:b2c_stock_out], status: StockLog::STATUS[:waiting], amount: available_amount, operation_type: StockLog::OPERATION_TYPE[:out])
  #           else
  #             stocklog.update_attribute(:amount, stocklog.amount + available_amount)
  #           end
  #           details.each do |x|
  #             x.stock_logs << stocklog
  #           end
  #           sklogs << stocklog
  #         end
  #       end
  #     else
  #       sklogs += details.first.stock_logs
  #     end
  #   end
  #   return sklogs
  # end

end
