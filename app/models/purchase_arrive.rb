class PurchaseArrive < ActiveRecord::Base
  belongs_to :purchase_detail
  has_many :stock_logs, dependent: :destroy
end
