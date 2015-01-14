class Specification < ActiveRecord::Base
   belongs_to :commodity
   has_one :unit, through: :commodity
   has_many :relationships

   validates_presence_of :commodity_id, :name, :message => '不能为空字符'
   # validates_uniqueness_of :sku, :message => '该商品已存在'

  before_save :set_all_name

  def full_title
    "#{commodity.name} #{name}"
  end

  def set_all_name
    self.all_name = full_title
  end

end
