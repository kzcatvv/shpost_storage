class ManualStock < ActiveRecord::Base
  belongs_to :unit
  belongs_to :business
  belongs_to :storage
  has_many :manual_stock_details, dependent: :destroy
  has_many :stocks, through: :manual_stock_details
  
  has_many :stock_logs, as: :parent
  has_many :tasks, as: :parent
  has_many :user_logs, as: :parent
  # alias :root_order :clone
  # alias :details :manual_stock_details
  # validates_presence_of :no, :name, message: '不能为空'

  STATUS = { opened: 'opened', closed: 'closed'}
  VIRTUAL = { 0=> '非虚拟', 1=> '虚拟'}

  def status_name
    status.blank? ? "" : self.class.human_attribute_name("status_#{status}")
  end

  def virtual_name
    virtual.blank? ? "" : self.class.human_attribute_name("virtual_#{virtual}")
  end

  def close
    if self.can_close?
      self.update(status: STATUS[:closed])
    else
      false
    end
  end

  def check!
    self.stock_logs.each do |x|
      x.check!
    end
    self.manual_stock_details.each do |detail|
      detail.stock_out
    end
  end

  def can_close?
    all_checked? #&& closed?
  end

  def all_checked?
    self.manual_stock_details.each do |x|
      if ! x.all_checked?
        return false
      end
    end
    return true
  end

  def has_checked?
    self.manual_stock_details.each do |x|
      if x.has_checked?
        return true
      end
    end
    return false
  end

  def closed?
    self.status.eql? STATUS[:closed]
  end

  def stock_log_operation
    StockLog::OPERATION[:b2b_stock_out]
  end

  def details
    manual_stock_details.includes(:manual_stock)
  end

  def waiting_amounts
    sum_stock_logs = self.stock_logs.includes(:manual_stock_detail).group("stock_logs.specification_id").group("stock_logs.supplier_id").group("stock_logs.business_id").group("manual_stock_details.defective").sum("stock_logs.amount")
    sum_amount = self.details.group(:specification_id, :supplier_id, :business_id, :defective).sum(:amount)

    # sum_stock_logs = self.stock_logs.group(:specification_id, :supplier_id, :business_id).sum(:amount)
    # sum_amount = self.details.group(:specification_id, :supplier_id, :business_id).sum(:amount)

    compare_sum_amount(sum_amount, sum_stock_logs)

    #compare without supplier
    if ! sum_amount.blank? && ! sum_stock_logs.blank?
      sum_stock_logs_without_supplier = {}
      sum_stock_logs.each do |x, amount|
        sum_stock_logs_without_supplier[[x[0], nil, x[2], x[3]]] = amount
      end
      compare_sum_amount(sum_amount, sum_stock_logs_without_supplier)
    end
    return sum_amount
  end

  def compare_sum_amount(sum_amount, sum_stock_logs)
    sum_amount.each do |x, amount|
      if sum_stock_logs[x].blank?
        sum_stock_logs[x] = 0
      end
      if sum_amount[x] >= sum_stock_logs[x]
        sum_amount[x] -= sum_stock_logs[x]
        sum_stock_logs[x] = 0
      else
        sum_stock_logs[x] -= sum_amount[x]
        sum_amount[x] = 0
      end
    end
    sum_stock_logs.delete_if {|key, value| value <= 0}
    sum_amount.delete_if {|key, value| value <= 0}
  end

  def has_waiting_stock_logs()
    x = self.stock_logs.where(status: "waiting").size
    if x == 0
      return false
    else
      return true
    end
  end
end
