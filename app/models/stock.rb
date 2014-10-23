class Stock < ActiveRecord::Base
  belongs_to :specification
  belongs_to :shelf
  belongs_to :business
  belongs_to :supplier
  # belongs_to :storage
  has_one :area, through: :shelf
  has_one :storage, through: :area
  has_one :unit, through: :storage
  has_many :stock_logs

  validates_presence_of :specification_id, :actual_amount, :virtual_amount

  scope :prior, ->{ includes(:shelf).order("shelves.priority_level ASC, virtual_amount DESC")}
  scope :available, -> { where("1 = 1")}

  def self.get_product_hash(order,detail,product_hash)
    product = [order.business,detail.specification,detail.supplier]
    if product_hash.has_key?(product)
        product_hash[product][0]=product_hash[product][0]+detail.amount
        product_hash[product][1]<<detail
    else
        product_hash[product]=[detail.amount, [detail]]
    end
    return product_hash
  end

  def self.check_out_stocks(order,details,current_storage)
    orderchk = true 
    details.each do |odl|
      hasout=odl.stock_logs.sum(:amount)
      if odl.amount - hasout > 0
       outstocks = Stock.find_stocks_in_storage(odl.specification, odl.supplier, order.business, current_storage).to_ary
       chkout = false
       amount = odl.amount - hasout
       outstocks.each do |stock|
        if !chkout
         if stock.virtual_amount - amount >= 0
            chkout = true
         else 
            amount = amount - stock.virtual_amount
            chkout = false
         end
        end
       end
       orderchk= orderchk && chkout
      end 
    end
    return orderchk
  end

  def self.stock_out(product_hash,current_storage,current_user)
    sklogs = []
    product_hash.each do |x|
      product = x[0]
      amount = x[1][0]
      details = x[1][1]
      # Rails.logger.info "-------product info--------"
      # Rails.logger.info product
      # Rails.logger.info "-------amount info--------"
      # Rails.logger.info amount
      if details.first.stock_logs.blank?
        outstocks = Stock.find_stocks_in_storage(product[1], product[2], product[0], current_storage).to_ary
        # Rails.logger.info "-------outstocks size--------"
        # Rails.logger.info outstocks.size
        outstocks.each do |outstock|
          # Rails.logger.info "-------------outstock----------------"
          # Rails.logger.info "-----------outstock info-------------"
          # Rails.logger.info outstock.id
          available_amount = outstock.get_available_amount
          # Rails.logger.info "----------available amount-----------"
          # Rails.logger.info available_amount
          if available_amount == 0
            next
          elsif available_amount >= amount
            outstock.update_attribute(:virtual_amount , outstock.virtual_amount - amount)
            outstock.save
            stocklog = StockLog.create(stock: outstock, user: current_user, operation: StockLog::OPERATION[:b2c_stock_out], status: StockLog::STATUS[:waiting], amount: amount, operation_type: StockLog::OPERATION_TYPE[:out])
            details.each do |x|
              x.stock_logs << stocklog
            end
            sklogs << stocklog
            break
          else
            amount = amount - available_amount
            outstock.update_attribute(:virtual_amount , outstock.virtual_amount - available_amount)
            outstock.save
            stocklog = StockLog.create(stock: outstock, user: current_user, operation: StockLog::OPERATION[:b2c_stock_out], status: StockLog::STATUS[:waiting], amount: available_amount, operation_type: StockLog::OPERATION_TYPE[:out])
            details.each do |x|
              x.stock_logs << stocklog
            end
            sklogs << stocklog
          end
        end
      else
        sklogs += details.first.stock_logs
      end
    end
    return sklogs
  end

  def self.get_available_stock(specification, supplier, business, batch_no, storage)
    stocks_in_storage_with_batch_no = in_storage(storage).find_stock(specification, supplier, business).with_batch_no(batch_no).available.prior

    stocks_in_storage_with_batch_no.each do |stock|
      return stock if stock.is_available?
    end

    stocks_in_storage_without_batch_no = in_storage(storage).find_stock(specification, supplier, business).without_batch_no(batch_no).available.prior

    stocks_in_storage_without_batch_no.each do |stock|
      if stock.is_available?
        available_stock = Stock.create(specification: specification, business: business, supplier: supplier, shelf: stock.shelf, batch_no: batch_no, actual_amount: 0, virtual_amount: 0)
        return available_stock
      end
    end

    shelf = Shelf.accessible_by(current_ability).get_neighbor_shelf stocks_in_storage_with_batch_no
    shelf ||= Shelf.accessible_by(current_ability).get_neighbor_shelf stocks_in_storage_without_batch_no
    shelf ||= Shelf.accessible_by(current_ability).get_empty_shelf
	shelf ||= Shelf.accessible_by(current_ability).get_default_shelf

    Stock.create(specification: specification, business: business, supplier: supplier, shelf: shelf, batch_no: batch_no, actual_amount: 0, virtual_amount: 0)
  end

  def self.find_stock_in_shelf_with_batch_no(specification, supplier, business, batch_no, shelf)
    in_shelf(shelf).find_stock(specification, supplier, business).with_batch_no(batch_no).first
  end

  def self.find_stock_in_storage(specification, supplier, business, storage)
    in_storage(storage).find_stock(specification, supplier, business).available.prior.first
  end

  def self.find_stocks_in_storage(specification, supplier, business, storage)
    in_storage(storage).find_stock(specification, supplier, business).available
  end

  def self.total_stock_in_unit(specification, supplier, business, unit)
    in_unit(unit).find_stock(specification, supplier, business).sum_virtual_amount
  end

  def self.total_stock_in_storage(specification, supplier, business, storage)
    in_storage(storage).find_stock(specification, supplier, business).sum_virtual_amount
  end

  def stock_in_amount(amount)
    stock_in_amount = available_amount(amount)
    self.virtual_amount += stock_in_amount
    stock_in_amount
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

  def available_amount(amount)
    amount
  end

  def is_available?
    true
  end

  def get_available_amount()
    return_amount = 0
    if self.actual_amount <= self.virtual_amount
      return_amount = self.actual_amount
    else
      return_amount = self.virtual_amount
    end
    return_amount
  end

  def self.warning_stocks(storage)
    select('specification_id as spec_id, business_id as b_id, supplier_id as s_id, sum(virtual_amount) as virtual_amount').joins(:storage).where('storages.id' => storage).group(:specification_id, :business_id, :supplier_id).having('sum(virtual_amount) < (?)', Relationship.select(:warning_amt).where('specification_id = spec_id and business_id = b_id and supplier_id = s_id'))
  end

  protected
  def self.sum_virtual_amount
    sum(:virtual_amount)
  end

  def self.find_stock(specification, supplier, business)
    conditions = where(specification: specification, business: business)

    if ! supplier.nil?
      conditions.where(supplier: supplier)
    end
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
