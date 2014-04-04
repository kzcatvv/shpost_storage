class OrderDetail < ActiveRecord::Base
  belongs_to :supplier
	belongs_to :specification
	belongs_to :order

	validates_presence_of :name, :message => '不能为空'
end
