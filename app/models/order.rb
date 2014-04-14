class Order < ActiveRecord::Base
  belongs_to :business
	belongs_to :unit
	belongs_to :storage
  belongs_to :keyclientorder
  has_many :order_details, dependent: :destroy

  validates_presence_of :no, :message => '不能为空'

  TYPE = { b2b: 'b2b', b2c: 'b2c' }
  # PAY_TYPE={ on_web: '网上支付', on_time: '货到付款' }
  STATUS = { waiting: 'waiting', printed: 'printed', picking: 'picking', delivering: 'delivering', delivered: 'delivered', declined: 'declined', returned: 'returned' }

  TRANSPORT_TYPE= { gnxb: 'gnxb', tcsd: 'tcsd', ems: 'ems'}

  def type_name
    status.blank? ? "" : self.class.human_attribute_name("status_#{status}")
  end

  def status_name
    status.blank? ? "" : self.class.human_attribute_name("status_#{status}")
  end

  def transport_type_name
    transport_type.blank? ? "" : self.class.human_attribute_name("transport_type_#{transport_type}")
  end
  # def paytypename
  #   Order::PAY_TYPE[pay_type.to_sym]
  # end

end
