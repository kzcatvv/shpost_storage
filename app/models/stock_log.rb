class StockLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :stock
  belongs_to :purchase_detail
  belongs_to :manual_stock_detail
  belongs_to :keyclientorderdetail

  has_one :shelf, through: :stock
  has_and_belongs_to_many :order_details
  has_many :orders, through: :order_details
  # has_many :keyclientorders, through: :orders
  belongs_to :parent, polymorphic: true


  OPERATION = {create_stock: 'create_stock', destroy_stock: 'destroy_stock', update_stock: 'update_stock', purchase_stock_in: 'purchase_stock_in', b2c_stock_out: 'b2c_stock_out', b2b_stock_out: 'b2b_stock_out', order_return: 'order_return',order_bad_return: 'order_bad_return',move_to_bad: 'move_to_bad',bad_stock_in: 'bad_stock_in'}
  OPERATION_SHOW = {create_stock: '新建库存', destroy_stock: '删除库存', update_stock: '更新库存', purchase_stock_in: '采购入库', b2c_stock_out: '订单出库', b2b_stock_out: '批量出库', order_return: '退货',order_bad_return: '残次品退货',move_to_bad: '残次品移入',bad_stock_in: '残次品入库'}
  STATUS = {waiting: 'waiting', checked: 'checked'}
  STATUS_SHOW = {waiting: '处理中', checked: '已确认'}

  OPERATION_TYPE = {in: 'in', out: 'out', reset: 'reset'}

  validates_presence_of :operation, :amount

  #before_create :set_desc
  before_save :set_desc
  before_save :set_stock_info

  def status_name
    status.blank? ? "" : self.class.human_attribute_name("status_#{status}")
  end

  def operation_name
    operation.blank? ? "" : self.class.human_attribute_name("operation_#{operation}")
  end

  def stock_out_name
    # stock_log : order_detail = N:1
    # self.order_details.first.specification.name + "_" + self.order_details.first.order.no
    self.order_details.first.specification.name
  end

  def set_desc
    if !stock.blank?
    self.desc = "#{OPERATION_TYPE[operation_type.to_sym]}#{stock.try(:specification).try(:commodity).try :name}-#{stock.try(:specification).try :model}共计#{self.amount}，批次：#{stock.batch_no}，商户：#{stock.try(:business).try :name}，供应商：#{stock.try(:supplier).try :name}，货架：#{stock.try(:shelf).try :shelf_code}"
    end
  end

  def set_stock_info
    if !stock.blank?
      self.shelf_id = stock.shelf_id
      self.business_id = stock.business_id
      self.supplier_id = stock.supplier_id
      self.specification_id = stock.specification_id
    end
  end

  def self.order_without_return
    where(operation: [OPERATION[:b2c_stock_out], OPERATION[:b2b_stock_out]])
  end

  def check!
    if self.waiting?
      if self.operation_type.eql? OPERATION_TYPE[:in]
        self.stock.check_in_amount self.amount
      elsif self.operation_type.eql? OPERATION_TYPE[:out]
        self.stock.check_out_amount self.amount
      elsif self.operation_type.eql? OPERATION_TYPE[:reset]
        self.stock.check_reset_amount self.amount
      end
      self.status = STATUS[:checked]
      self.checked_at = Time.now

      StockLog.transaction do
        self.save
        self.stock.save

        if self.belongs_to_purchase?
          self.purchase_detail.stock_in
        end

        if self.belongs_to_order?
          self.orders.each{|order| order.checked }
        end

        if self.belongs_to_manual_stock?
          ManualStockDetail.find(self.manual_stock_detail_id).stock_out
        end
      end
    end
  end


  # def order_check
  #   #binding.pry
  #   if self.waiting?
  #     if self.operation_type.eql? OPERATION_TYPE[:in]
  #       self.stock.check_in_amount self.amount
  #     elsif self.operation_type.eql? OPERATION_TYPE[:out]
  #       self.stock.check_out_amount self.amount
  #     elsif self.operation_type.eql? OPERATION_TYPE[:reset]
  #       self.stock.check_reset_amount self.amount
  #     end
  #     self.status = STATUS[:checked]
  #     self.checked_at = Time.now

  #     StockLog.transaction do
  #       self.save
  #       self.stock.save
  #     end
  #   end
  # end

  def belongs_to_purchase?
    ! self.purchase_detail.blank?
  end

  def belongs_to_order?
    ! self.order_details.blank?
  end

  def belongs_to_manual_stock?
    ! self.manual_stock_detail_id.blank?
  end

  def checked?
    self.status.eql? STATUS[:checked]
  end

  def waiting?
    self.status.eql? STATUS[:waiting]
  end

  
end
