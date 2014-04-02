class Commodity < ActiveRecord::Base
	belongs_to :unit
	belongs_to :goodstype
	validates_presence_of :cno, :name, :message => '不能为空'
	validates_uniqueness_of :cno, :message => '该商品已存在'
end
