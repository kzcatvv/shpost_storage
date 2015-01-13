class StockLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :stock, touch: true
  belongs_to :purchase_detail
  belongs_to :manual_stock_detail
  belongs_to :keyclientorderdetail
  belongs_to :specification
  belongs_to :shelf
  belongs_to :business
  belongs_to :supplier

  # has_one :shelf, through: :stock
  has_one :area, through: :shelf
  has_one :storage, through: :shelf
  has_one :unit, through: :shelf
  has_and_belongs_to_many :order_details
  has_many :orders, through: :order_details
  # has_many :keyclientorders, through: :orders
  belongs_to :parent, polymorphic: true
  belongs_to :relationship

  belongs_to :pick, :class_name => 'StockLog'
  has_one :pick_in, :class_name => 'StockLog',:foreign_key => 'pick_id'#,:dependent => :destroy

  validates_presence_of :operation, :amount

  #before_create :set_desc
  before_save :set_desc
  before_save :set_stock_info
  
  # OPERATION_HASH = {[Purchase, 'in'] => OPERATION[:purchase_stock_in], [ManualStock, 'out'] => OPERATION[:b2b_stock_out], [Keyclientorder, 'out'] => OPERATION[:b2c_stock_out], [OrderReturn, 'in'] => OPERATION[:order_return]}
  OPERATION = {create_stock: 'create_stock', destroy_stock: 'destroy_stock', update_stock: 'update_stock', purchase_stock_in: 'purchase_stock_in', b2c_stock_out: 'b2c_stock_out', b2b_stock_out: 'b2b_stock_out', order_return: 'order_return',order_bad_return: 'order_bad_return',move_to_bad: 'move_to_bad',bad_stock_in: 'bad_stock_in',move_stock_out: 'move_stock_out',move_stock_in: 'move_stock_in'}
  OPERATION_SHOW = {create_stock: '新建库存', destroy_stock: '删除库存', update_stock: '更新库存', purchase_stock_in: '采购入库', b2c_stock_out: '订单出库', b2b_stock_out: '批量出库', order_return: '退货',order_bad_return: '残次品退货',move_to_bad: '残次品移入',bad_stock_in: '残次品入库',move_stock_out: '货品移出',move_stock_in: '货品移入'}
  STATUS = {waiting: 'waiting', checked: 'checked'}
  STATUS_SHOW = {waiting: '处理中', checked: '已确认'}

  OPERATION_TYPE = {in: 'in', out: 'out', reset: 'reset'}

  

  def status_name
    status.blank? ? "" : self.class.human_attribute_name("status_#{status}")
  end

  def operation_name
    operation.blank? ? "" : self.class.human_attribute_name("operation_#{operation}")
  end

  def stock_out_name
    # stock_log : order_detail = N:1
    # self.order_details.first.specification.name + "_" + self.order_details.first.order.no
    self.specification.name
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

      if !self.sn.blank?
        self.stock.update_sn(self.sn, self.operation_type)
      end

      self.status = STATUS[:checked]
      self.checked_at = Time.now



      self.save
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

  def self.in_unit(unit)
    includes(:unit).where('units.id' => unit)
  end

  def self.in_storage(storage)
    includes(:storage).where('storages.id' => storage)
  end

  def self.operation_in
    where(operation_type: StockLog::OPERATION_TYPE[:in])
  end

  def self.operation_out
    where(operation_type: StockLog::OPERATION_TYPE[:out])
  end

  def self.find_stock_logs(specification, supplier, business)
    where(specification: specification, supplier: supplier, business: business)
  end

  def self.waiting
    where(status: StockLog::STATUS[:waiting])
  end

  def self.checked
    where(status: StockLog::STATUS[:checked])
  end

  def self.virtual_amount_in_unit(specification, supplier, business, unit)
    StockLog.in_unit(unit).waiting.operation_in.find_stock_logs(specification, supplier, business).sum(:amount) - StockLog.in_unit(unit).waiting.operation_out.find_stock_logs(specification, supplier, business).sum(:amount)
  end

  def self.virtual_amount_in_storage(specification, supplier, business, unit)
    StockLog.in_storage(storage).waiting.operation_in.find_stock_logs(specification, supplier, business).sum(:amount) - StockLog.in_storage(storage).waiting.operation_out.find_stock_logs(specification, supplier, business).sum(:amount)
  end

  def update_amount(total_amount)
    if operation.eql? OPERATION[:purchase_stock_in]
      max_amount = self.parent.purchase_arrivals.where(batch_no: self.batch_no).sum(:arrived_amount) - self.parent.stock_logs.where(batch_no: self.batch_no).where.not(id: self.id).sum(:amount)
      if total_amount > max_amount
        total_amount = max_amount
      end
    elsif operation.eql? OPERATION[:move_stock_out]
      max_amount = self.stock.actual_amount
    elsif operation.eql? OPERATION[:b2b_stock_out]
      on_shelf_amount = self.stock.on_shelf_amount
      left_amount = self.parent.manual_stock_details.includes(:manual_stock).where(supplier: self.supplier, specification: self.specification, manual_stocks: {business_id: self.business_id}).sum(:amount) - self.parent.stock_logs.where(supplier: self.supplier, specification: self.specification, business: self.business).where.not(id: self.id).sum(:amount)
      max_amount = (on_shelf_amount < left_amount) ? on_shelf_amount : left_amount
    elsif operation.eql? OPERATION[:b2c_stock_out]
      on_shelf_amount = self.stock.on_shelf_amount
      left_amount = self.parent.order_details.includes(:order).where(supplier: self.supplier, specification: self.specification, orders: {business_id: self.business_id}).sum(:amount) - self.parent.stock_logs.where(supplier: self.supplier, specification: self.specification, business: self.business).where.not(id: self.id).sum(:amount)
      
      max_amount = (on_shelf_amount < left_amount) ? on_shelf_amount : left_amount
    end

    total_amount = max_amount if total_amount > max_amount

    self.update(amount: total_amount)
    self.pick_in.update(amount: total_amount) if !self.pick_in.blank?
  end

  private
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
      self.expiration_date = stock.expiration_date if !stock.expiration_date.blank?
      self.batch_no = stock.batch_no if !stock.batch_no.blank?
      self.relationship = stock.relationship
      # self.sn = stock.sn
    end
  end

  # def clean_stock_association
  #   self.update(stock: nil)
  # end
end
