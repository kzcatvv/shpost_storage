class Stock < ActiveRecord::Base
  belongs_to :specification
  belongs_to :shelf
  belongs_to :business
  belongs_to :supplier
  has_many :stock_logs

  validates_presence_of :specification_id, :actual_amount, :virtual_amount

  scope :prior, ->{ includes(:shelf).order("shelves.priority_level ASC, virtual_amount DESC")}
  scope :available, -> { where("1 = 1")}

  def self.find_with_batch_no(specification, business, supplier, batch_no)
    where(specification: specification, business: business, supplier: supplier, batch_no: batch_no)
  end

  def self.find_without_batch_no(specification, business, supplier, batch_no)
    where(specification: specification, business: business, supplier: supplier).where(["batch_no != ?", batch_no])
  end

  def self.find_key(specification, business, supplier, batch_no)
    find_with_batch_no(specification, business, supplier, batch_no).available.prior + find_without_batch_no(specification, business, supplier, batch_no).available.prior
  end

  def self.get_available_stock(specification, business, supplier, batch_no)
    stocks_with_batch_no = find_with_batch_no(specification, business, supplier, batch_no)

    stocks_with_batch_no.each do |stock|
      return stock if stock.is_available?
    end

    stocks_without_batch_no = find_without_batch_no(specification, business, supplier, batch_no)

    stocks_without_batch_no.each do |stock|
      if stock.is_available?
        available_stock = Stock.create(specification: specification, business: business, supplier: supplier, shelf: stock.shelf, batch_no: batch_no, actual_amount: 0, virtual_amount: 0)
        return available_stock
      end
    end

    shelf = Shelf.get_neighbor_shelf stocks_with_batch_no
    shelf ||= Shelf.get_neighbor_shelf stocks_without_batch_no
    shelf ||= Shelf.get_empty_shelf

    Stock.create(specification: specification, business: business, supplier: supplier, shelf: shelf, batch_no: batch_no, actual_amount: 0, virtual_amount: 0)
  end

  def self.get_stock(specification, business, supplier, batch_no, shelf, amount)
    stock = self.find_with_batch_no(specification, business, supplier, batch_no).where(shelf: shelf).first
  end

  def self.find_out_stock(specification, business, supplier)
    where(specification: specification, business: business, supplier: supplier)
  end

  def self.find_stock_amount(specification, business, supplier)
    where(specification: specification, business: business, supplier: supplier, ).sum(:virtual_amount)
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
end
