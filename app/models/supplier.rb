class Supplier < ActiveRecord::Base
	belongs_to :unit
	validates_presence_of :no, :name, :message => '不能为空'
	validates_uniqueness_of :no, :message => '该编号已存在'
end
