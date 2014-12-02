class PurchaseArrival < ActiveRecord::Base
  belongs_to :purchase_detail
  has_one :unit, through: :purchase_detail
end
