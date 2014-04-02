class Commodity < ActiveRecord::Base
	belongs_to :unit
	belongs_to :gooodstype
	has_many :specifications, dependent: :destroy
	validates_presence_of :cno, :name, :message => '不能为空'
	validates_uniqueness_of :cno, scope: :unit_id, :message => '该商品已存在'
end
