class StockLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :stock

  OPERATION = {create_stock: 'create_stock', destroy_stock: 'destroy_stock', update_stock: 'update_stock', purchase_stock_in: 'purchase_stock_in'}
  STATUS = {waiting: 'waiting', checked: 'checked'}
  OPERATION_TYPE = {in: 'in', out: 'out', reset: 'reset'}

  validates_presence_of :operation, :amount

  #before_create :set_desc
  before_save :set_desc

  def set_desc
    self.desc = "#{OPERATION_TYPE[operation_type.to_sym]}#{stock.specification.try(:commodity).try :name}-#{stock.specification.try :model}共计#{stock.actual_amount}，批次：#{stock.batch_no}，商户：#{stock.business.try :name}，供应商：#{stock.supplier.try :name}，货架：#{stock.shelf.try :shelf_code}"
  end
end
