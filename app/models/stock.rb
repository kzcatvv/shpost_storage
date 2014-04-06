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
    stocks = find_key(specification, business, supplier, batch_no)

    if !stocks.blank?
      stocks.each do |stock|
        return stock if stock.is_available?
      end

      shelf = Shelf.get_neighbor_shelf stocks
    else
      shelf = Shelf.get_empty_shelf
    end

    Stock.create(specification: specification, business: business, supplier: supplier, shelf: shelf, batch_no: batch_no, actual_amount: 0, virtual_amount: 0)
  end

  def push_amount(amount)
    push_amount = available_amount(amount)
    self.virtual_amount += push_amount
    push_amount
  end

  def available_amount(amount)
    amount
  end

  def is_available?
    true
  end
end
