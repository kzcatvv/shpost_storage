class StockLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :stock

  OPERATION = {create_stock: '新增库存', destroy_stock: '删除库存', update_stock: '修改库存'}
  STATUS = {waiting: '待确认', checked: '已确认'}
  OPERATION_TYPE = {in: '入库',out: '出库', reset: '重置'}

  validates_presence_of :operation, :amount

  #before_create :set_desc
  before_save :set_desc

  def set_desc
    self.desc = "#{OPERATION_TYPE[operation_type.to_sym]}#{stock.specification.try(:commodity).try :name}-#{stock.specification.try :desc}共计#{stock.actual_amount}，批次：#{stock.batch_no}，商户：#{stock.business.try :name}，供应商：#{stock.supplier.try :name}，货架：stock.shelf.try :no"
  end
end
