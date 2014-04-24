class Order < ActiveRecord::Base
  belongs_to :business
	belongs_to :unit
	belongs_to :storage
  belongs_to :keyclientorder
  has_many :order_details, dependent: :destroy
  has_many :stock_logs, through: :order_details

  before_save :set_no

  validates_presence_of :no, :message => '不能为空'

  TYPE = { b2b: 'b2b', b2c: 'b2c' }
  # PAY_TYPE={ on_web: '网上支付', on_time: '货到付款' }
  STATUS = { waiting: 'waiting', printed: 'printed', checked: 'checked', picking: 'picking', delivering: 'delivering', delivered: 'delivered', declined: 'declined', returned: 'returned' }

  TRANSPORT_TYPE= { gnxb: 'gnxb', tcsd: 'tcsd', ems: 'ems'}

  SHORTAGE_TYPE = { yes: 'yes', no: 'no' }

  def type_name
    order_type.blank? ? "" : self.class.human_attribute_name("order_type_#{order_type}")
  end

  def status_name
    status.blank? ? "" : self.class.human_attribute_name("status_#{status}")
  end

  def transport_type_name
    transport_type.blank? ? "" : self.class.human_attribute_name("transport_type_#{transport_type}")
  end

  def shortage_type_name
    is_shortage.blank? ? "" : self.class.human_attribute_name("is_shortage_#{is_shortage}")
  end

  def checked_amount
    self.stock_logs.to_a.sum{|x| x.checked? ? x.amount : 0}
  end

  def all_checked?
    self.order_details.sum(:amount).eql? self.checked_amount
  end

  def stock_out
    if self.all_checked?
      self.update(status: STATUS[:checked])
    else
      false
    end
  end

  protected

  def set_no
    if self.blank?
      time = time.now
      self.no = time.year.to_s + time.month.to_s.rjust(2,'0') + time.day.to_s.rjust(2,'0') + Order.count.to_s.rjust(5,'0')
    end
  end
  # def paytypename
  #   Order::PAY_TYPE[pay_type.to_sym]
  # end

end
