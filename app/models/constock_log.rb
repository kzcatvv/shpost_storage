class ConstockLog < ActiveRecord::Base
	belongs_to :user
	belongs_to :consumable_stock
end
