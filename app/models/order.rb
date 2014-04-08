class Order < ActiveRecord::Base
  belongs_to :business
	belongs_to :unit
	belongs_to :storage
  belongs_to :keyclientorder

  TYPE = { keyclientorder: '大客户订单', pubiicclient: '电商订单' }
  PAY_TYPE={ on_web: '网上支付', on_time: '货到付款' }
  STATUS = { untreated: '未处理', processing: '处理中' ,processed: '处理完毕'}
  TRANSPORT_TYPE= { ems: 'ems'}
  def paytypename
    Order::PAY_TYPE[pay_type.to_sym]
  end

  def statusname
    Order::STATUS[status.to_sym]
  end

  def transporttypename
    Order::TRANSPORT_TYPE[transport_type.to_sym]
  end
   
	  has_many :order_detail, dependent: :destroy
		validates_presence_of :no, :message => '不能为空'
end
