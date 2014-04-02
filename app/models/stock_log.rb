class StockLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :stock

  OPERATION = {create_stock: '新建库存', destroy_stock: '删除库存', update_stock: '修改库存'}
  STATUS = {waiting: '待确认', checked: '已确认'}
  OPERATION_TYPE = {reset: '重置'}

  validates_presence_of :operation, :amount
end
