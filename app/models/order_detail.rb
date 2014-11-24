class OrderDetail < ActiveRecord::Base
  belongs_to :supplier
	belongs_to :specification
	belongs_to :order
  has_one :unit, through: :order
  has_one :order_return_detail
	has_and_belongs_to_many :stock_logs

	# validates_presence_of :name, :message => '不能为空'


  def all_checked?
    self.amount.eql? self.checked_amount
  end

  def checked_amount
    self.stock_logs.order_without_return.to_a.sum{|x| x.checked? ? x.amount : 0}
  end
end
