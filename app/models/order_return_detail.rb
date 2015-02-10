class OrderReturnDetail < ActiveRecord::Base
  belongs_to :order_return
  belongs_to :order_detail
  has_one :order, through: :order_detail
  has_one :unit, through: :order_detail


  def set_checked
      self.update(status: "checked")
  end

  def broken?
    (is_bad.eql? 'yes') ? true : false
  end
end
