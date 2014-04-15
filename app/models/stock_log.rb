class StockLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :stock
  belongs_to :purchase_detail

  OPERATION = {create_stock: 'create_stock', destroy_stock: 'destroy_stock', update_stock: 'update_stock', purchase_stock_in: 'purchase_stock_in'}
  STATUS = {waiting: 'waiting', checked: 'checked'}
  OPERATION_TYPE = {in: 'in', out: 'out', reset: 'reset'}

  validates_presence_of :operation, :amount

  #before_create :set_desc
  before_save :set_desc

  def set_desc
    if !stock.blank?
    self.desc = "#{OPERATION_TYPE[operation_type.to_sym]}#{stock.try(:specification).try(:commodity).try :name}-#{stock.try(:specification).try :model}共计#{self.amount}，批次：#{stock.batch_no}，商户：#{stock.try(:business).try :name}，供应商：#{stock.try(:supplier).try :name}，货架：#{stock.try(:shelf).try :shelf_code}"
    end
  end

  def check
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
      end
    end
  end

  def belongs_to_purchase?
    ! self.purchase_detail.blank?
  end
  def checked?
    self.status.eql? STATUS[:checked]
  end

  def waiting?
    self.status.eql? STATUS[:waiting]
  end
end
