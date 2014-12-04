class Keyclientorder < ActiveRecord::Base
  has_many :keyclientorderdetails, dependent: :destroy
  has_many :orders
  has_many :order_details, through: :orders
  has_many :stock_logs, as: :parent
  belongs_to :unit
  belongs_to :storage
  belongs_to :business
  belongs_to :user

  # before_validation :set_batch_id

  validates_presence_of :keyclient_name, :unit_id, :storage_id, :message => '不能为空'

  STATUS = { waiting: 'waiting', printed: 'printed', picking: 'picking', checked: 'checked', packed: 'packed', delivering: 'delivering', delivered: 'delivered', declined: 'declined', returned: 'returned' }
  
  STATUS_SHOW = { waiting: '待处理', printed: '已打印', picking: '正在拣货', checked: '已审核', packed: '已包装', delivering: '正在寄送中', delivered: '已寄达', declined: '拒收', returned: '退回' }
  # validates_uniqueness_of :batch_id, :message => '该订单批次编号已存在'

  # def set_batch_id
  #   if self.batch_id.blank?
  #     time = Time.now
  #     self.batch_id = time.year.to_s + time.month.to_s.rjust(2,'0') + time.day.to_s.rjust(2,'0') + Keyclientorder.count.to_s.rjust(5,'0')
  #   end
  # end
  def stock_log_operation
    StockLog::OPERATION[:b2c_stock_out]
  end

  def status_name
    status.blank? ? "" : Keyclientorder::STATUS_SHOW["#{status}".to_sym]
  end

  def details
    order_details
  end

  def picking_out
      self.update(status: STATUS[:picking])
      self.orders.each do |x|
        x.set_picking
      end
  end

  def check_out
    if all_checked?
      self.update(status: STATUS[:checked])
      self.orders.each do |x|
        x.stock_out
      end
    end
  end

  def all_checked?
    self.stock_logs.each do |x|
      if ! x.checked?
        return false
      end
    end
    return true
  end

  def check!
    self.stock_logs.each do |x|
      x.check!
    end

    self.orders.each do |order|
      order.stock_out
    end
  end

  def waiting_amounts
    sum_stock_logs = self.stock_logs.group(:specification_id, :supplier_id, :business_id).sum(:amount)
    sum_amount = self.details.group(:specification_id, :supplier_id, :business_id).sum(:amount)

    sum_amount.each do |x, amount|
      sum_amount[x] -= sum_stock_logs[x].blank? ? 0 : sum_stock_logs[x]
    end

    sum_amount.delete_if {|key, value| value <= 0}
  end
end
