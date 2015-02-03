class OrderReturn < ActiveRecord::Base
  belongs_to :unit
  belongs_to :storage
  has_many :stock_logs, as: :parent
  has_many :order_return_details, dependent: :destroy
  has_many :tasks, as: :parent
  has_many :user_logs, as: :parent

  def all_checked?
    self.stock_logs.each do |x|
      if ! x.checked?
        return false
      end
    end
    return true
  end

  def check!
    self.stock_logs.each do |x|
      x.check!
    end

    if self.all_checked?

      self.order_return_details.each do |order_return_detail|
        order_return_detail.set_checked
      end

      self.update(status: "checked")

      self.order_return_details.first.order.update(status: "returned")
    end
  end

end
