class OrderReturn < ActiveRecord::Base
  belongs_to :unit
  belongs_to :storage
  has_many :stock_logs, as: :parent
  has_many :order_return_details, dependent: :destroy

  def check!
    self.stock_logs.each do |x|
      x.check!
    end

    self.order_return_details.each do |order_return_detail|
      order_return_detail.return_in
    end
  end
end
