class Specification < ActiveRecord::Base
   belongs_to :commodity
   has_one :unit, through: :commodity

   validates_presence_of :commodity_id, :name, :message => '不能为空字符'
   # validates_uniqueness_of :sku, :message => '该商品已存在'

  def full_title
    "#{commodity.name} #{name}"
  end
end
