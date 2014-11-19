class OrderReturn < ActiveRecord::Base
	has_many :order_return_details, dependent: :destroy
  belongs_to :unit
end
