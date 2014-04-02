class Purchase < ActiveRecord::Base
	belongs_to :unit
	belongs_to :bussiness
	validates_presence_of :no, :message => '不能为空'
end
