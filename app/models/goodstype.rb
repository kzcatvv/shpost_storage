class Goodstype < ActiveRecord::Base
	belongs_to :unit
	validates_presence_of :gtno, :name, :message => '不能为空'
	validates_uniqueness_of :gtno, :name, :message => '该商品类型已存在'
end
