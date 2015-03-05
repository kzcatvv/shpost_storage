class Consumable < ActiveRecord::Base
	belongs_to :unit
	belongs_to :storage
	belongs_to :business
	belongs_to :supplier
end
