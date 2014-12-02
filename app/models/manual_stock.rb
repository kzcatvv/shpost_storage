class ManualStock < ActiveRecord::Base
  belongs_to :unit
  belongs_to :business
  belongs_to :storage
  has_many :manual_stock_details, dependent: :destroy
  has_many :stocks, through: :manual_stock_details
  
  has_many :stock_logs, as: :parent 

  # alias :root_order :clone
  # alias :details :manual_stock_details
  # validates_presence_of :no, :name, message: '不能为空'

  STATUS = { opened: 'opened', closed: 'closed'}

  def status_name
    status.blank? ? "" : self.class.human_attribute_name("status_#{status}")
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
    sum_stock_logs = self.stock_logs.group(:specification_id, :supplier_id, :business_id).sum(:amount)
    sum_amount = self.details.group(:specification_id, :supplier_id, :business_id).sum(:amount)

    sum_amount.each do |x, amount|
      sum_amount[x] -= sum_stock_logs[x].blank? ? 0 : sum_stock_logs[x]
    end

    sum_amount.delete_if {|key, value| value <= 0}
  end

end
