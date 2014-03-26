class Purchasedetail < ActiveRecord::Base
	belongs_to :specification
	belongs_to :supplier
	belongs_to :purchase
	validates_presence_of :name, :message => '不能为空'
end
