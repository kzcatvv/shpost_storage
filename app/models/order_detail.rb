class OrderDetail < ActiveRecord::Base
  belongs_to :supplier
	belongs_to :specification
	belongs_to :order
	has_and_belongs_to_many :stock_logs

	validates_presence_of :name, :message => '不能为空'

end
