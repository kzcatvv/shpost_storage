class OrderReturn < ActiveRecord::Base
	belongs_to :order_detail
  has_one :order, through: :order_detail
  has_one :unit, through: :order

  def return_amount
    OrderDetail.find(self.order_detail_id).stock_logs.where("operation = 'order_return'").to_a.sum{|x| x.checked? ? x.amount : 0}
  end

  def all_return_checked?
    OrderDetail.find(self.order_detail_id).amount.eql? self.return_amount
  end

  def return_in
    if self.all_return_checked?
      self.update(status: "checked")
    else
      false
    end
  end
end
