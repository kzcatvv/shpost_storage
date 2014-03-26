class Supplier < ActiveRecord::Base
	belongs_to :unit
	validates_presence_of :sno, :name, :address, :phone, :message => '不能为空'
	validates_uniqueness_of :sno, :message => '该编号已存在'
end
