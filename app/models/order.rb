class Order < ActiveRecord::Base
  belongs_to :business
	belongs_to :unit
	belongs_to :storage
  belongs_to :keyclientorder
  belongs_to :parent, :class_name => 'Order'
  belongs_to :logistic
  has_many :order_details, dependent: :destroy
  has_many :stock_logs, through: :order_details
  has_many :deliver_notices
  has_many :children, :class_name => 'Order',:foreign_key => 'parent_id',:dependent => :destroy
  has_and_belongs_to_many :user_logs

  # alias :root_order :keyclientorder
  # alias :details :order_details
  # before_validation :set_no

  # validates_presence_of :no, :message => '不能为空'

  TYPE = { b2b: 'b2b', b2c: 'b2c' }
  # PAY_TYPE={ on_web: '网上支付', on_time: '货到付款' }
  STATUS = { waiting: 'waiting', spliting: 'spliting', splited: 'splited', printed: 'printed', picking: 'picking', checked: 'checked', packed: 'packed', delivering: 'delivering', delivered: 'delivered', declined: 'declined', returned: 'returned', cancel: 'cancel' }

  # STATUS = { waiting: '待处理', printed: '已打印', picking: '拣货中', checked: '已审核', packed: '已包装', delivering: '配送中', delivered: '已签收', declined: '拒收', returned: '已退回' }

  PACKAGING_STATUS = [Order::STATUS[:waiting] , Order::STATUS[:printed], STATUS[:picking], STATUS[:checked]]

  PACKAGED_STATUS = [Order::STATUS[:packed] , Order::STATUS[:delivering], STATUS[:delivered], STATUS[:declined], STATUS[:returned]]

  STATUS_SHOW = { waiting: '待处理',spliting: '拆单中', splited: '已拆单', printed: '已打印', picking: '正在拣货', checked: '已审核', packed: '已包装', delivering: '正在寄送中', delivered: '已寄达', declined: '拒收', returned: '退回', cancel: '取消' }


  TRANSPORT_TYPE= { gnxb: '国内小包', tcsd: '同城小包', ems: 'EMS', ttkd: '天天快递', bsht: '百世汇通', qt: '其他'}

  TRANSPORT_TYPE_print= {'国内小包'=>'gnxb', '同城速递'=>'tcsd', '同城小包'=>'tcsd', 'EMS'=>'ems', '天天快递'=>'ttkd', '百世汇通'=>'bsht', '其他'=>'qt'}


  SHORTAGE_TYPE = { yes: '可能缺货', no: '可能有货' }

  PARENT_TYPE = { true: '否', false: '是'}

  

  def type_name
    order_type.blank? ? "" : self.class.human_attribute_name("order_type_#{order_type}")
  end

  def status_name
    status.blank? ? "" : Order::STATUS_SHOW["#{status}".to_sym]
  end

  def transport_type_name
    transport_type.blank? ? "" : self.class.human_attribute_name("transport_type_#{transport_type}")
  end

  def shortage_type_name
    is_shortage.blank? ? "" : Order::SHORTAGE_TYPE["#{is_shortage}".to_sym]
  end

  def parent_type_name
     if is_split
        name = "是"
     else
        name = "否"
     end
   end

  def checked_amount
    self.stock_logs.where("operation <> 'order_return'").to_a.sum{|x| x.checked? ? x.amount : 0}
  end

  # def all_checked?
  #   self.order_details.sum(:amount).eql? self.checked_amount
  # end

  def has_b2b_split_orders?
    if self.order_type.eql? 'b2b' and !self.is_split
      x = self.keyclientorder.orders
      x.each do |o|
        if o.order_type.eql? 'b2c' and o.is_split
          return true
        end
      end
    end
    return false
  end

  def get_b2b_split_orders
    return_orders = []
    x = self.keyclientorder.orders
    x.each do |o|
      if o.order_type.eql? 'b2c' and o.is_split
        return_orders << o
      end
    end
    return return_orders
  end

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

  def checked?
    self.status.eql? STATUS[:checked]
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

  def b2bsetsplitstatus
    self.update(status: STATUS[:packed])

    if self.b2b_can_update_parent
      self.parent.update(status: STATUS[:packed])
      self.parent.keyclientorder.update(status: STATUS[:packed])
    end
  end

  def b2csetsplitstatus
    self.update(status: STATUS[:packed])

    if self.b2b_can_update_parent
      self.parent.update(status: STATUS[:packed])
    end
  end

  def b2b_can_update_parent
    po_amount=self.parent.order_details.sum(:amount)
    co_amount=0
    self.parent.children.each do |x|
        co_amount += x.order_details.sum(:amount)
    end
    if po_amount == co_amount
      self.parent.children.each do |j|
        if j.status != "packed"
          return false
        end
      end
      return true
    else
      return false
    end
  end

  def to_row
    row = []
    row << business_order_id
    row << tracking_number
    row << transport_type
    row << total_weight
    row << pingan_ordertime
    row << customer_unit
    row << customer_name
    row << customer_address
    row << customer_postcode
    row << province
    row << city
    row << county
    row << customer_tel
    row << customer_phone
    row << business.no
    row << business.name
    row << batch_no
    row << business_trans_no
    row << status
    row << nil
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

  def stock_log_operation
    StockLog::OPERATION[:b2c_stock_out]
  end

  
end
