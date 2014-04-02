class Specification < ActiveRecord::Base
   belongs_to :commodity

   validates_presence_of :commodity_id, :product_no, :name, :message => '不能为空字符'
   validates_uniqueness_of :product_no, :message => '该商品已存在'
end
