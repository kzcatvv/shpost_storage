class OrderReturn < ActiveRecord::Base
  belongs_to :unit
  belongs_to :storage
  has_many :stock_logs, as: :parent
  has_many :order_return_details, dependent: :destroy

end
