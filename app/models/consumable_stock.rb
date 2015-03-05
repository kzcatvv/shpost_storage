class ConsumableStock < ActiveRecord::Base
	belongs_to :unit
	belongs_to :storage
	belongs_to :consumable
end
