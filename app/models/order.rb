class Order < ActiveRecord::Base
  belongs_to :business
	belongs_to :unit
	belongs_to :storage
  belongs_to :keyclientorder
  has_many :order_details, dependent: :destroy
  has_many :stock_logs, through: :order_details
  has_many :deliver_notices

  # before_validation :set_no

  # validates_presence_of :no, :message => '不能为空'

  TYPE = { b2b: 'b2b', b2c: 'b2c' }
  # PAY_TYPE={ on_web: '网上支付', on_time: '货到付款' }
  STATUS = { waiting: 'waiting', printed: 'printed', picking: 'picking', checked: 'checked', packed: 'packed', delivering: 'delivering', delivered: 'delivered', declined: 'declined', returned: 'returned' }

  STATUS_SHOW = { waiting: '待处理', printed: '已打印', picking: '正在拣货', checked: '已审核', packed: '已包装', delivering: '正在寄送中', delivered: '已寄达', declined: '拒收', returned: '退回' }

  TRANSPORT_TYPE= { gnxb: '国内小包', tcsd: '同城速递', ems: 'EMS'}

  TRANSPORT_TYPE_print= {'国内小包'=>'gnxb', '同城速递'=>'tcsd', 'EMS'=>'ems'}

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
    self.stock_logs.where("operation <> 'order_return'").to_a.sum{|x| x.checked? ? x.amount : 0}
  end

  # def all_checked?
  #   self.order_details.sum(:amount).eql? self.checked_amount
  # end

  def checked
    if all_checked?
      self.update(status: STATUS[:checked])
    end
  end

  def all_checked?
    self.order_details.each do |x|
      if ! x.all_checked?
        return false
      end
    end
    return true
  end

  def stock_out
    # if self.all_checked?
    if can_update_status(STATUS[:checked])
      self.update(status: STATUS[:checked])
    end
    # else
    #   false
    # end
  end

  def set_picking
    if can_update_status(STATUS[:picking])
      self.update(status: STATUS[:picking])
    end
  end

  def set_status(status)
    if can_update_status(status)
      self.update(status: status)
    end
  end

  def can_import()
    order = Order.find self
    if order.blank?
      return true
    else
      x = compare_status(order.status,"printed")
      if x.blank?
        return false
      elsif x == 0
        return true
      elsif x > 0
        return false
      elsif x < 0
        return true
      end
    end
  end

  protected

  def can_update_status(status)
    x = compare_status(self.status, status)
    if x.blank?
      return false
    elsif x > 0
      return false
    elsif x == 0
      return true
    elsif x < 0
      return true
    end
    # default
    return false
  end

  # def set_no
  #   if self.no.blank?
  #     time = Time.now
  #     self.no = time.year.to_s + time.month.to_s.rjust(2,'0') + time.day.to_s.rjust(2,'0') + Order.count.to_s.rjust(5,'0')
  #   end
  # end
  # def paytypename
  #   Order::PAY_TYPE[pay_type.to_sym]
  # end

  def compare_status(first, second)
    # if equle return 0, first > second return 1, first < second return -1
    if first == second
      return 0
    end
    STATUS.each do |key, value|
      if first == value && second != value
        return -1
      elsif first != value && second == value
        return 1
      else
        next
      end
    end
    # status invalid
    return nil
  end

end
