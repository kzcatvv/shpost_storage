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

  STATUS_SHOW_INDEX = { waiting: '待处理',spliting: '拆单中', printed: '已打印'}

  # TRANSPORT_TYPE= { gnxb: '国内小包', tcsd: '同城小包', ems: 'EMS', ttkd: '天天快递', bsht: '百世汇通', qt: '其他'}
  TRANSPORT_TYPE = Logistic.pluck(:print_format,:name).to_h

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

  def is_printed_name
    if is_printed
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

  def self.find_stock(orders,createKeyCilentOrderFlg,type='0')
    order_details_hash = orders.unscope(:order).unscope(:includes).joins(:order_details).group(:specification_id, :supplier_id, :business_id).sum(:amount)
    orders.update_all(is_shortage: 'no')
    orders_changed = false
    order_details_hash.each do |key, sum|
      stock_sum = Stock.total_stock_in_storage(Specification.find(key[0]), key[1].blank? ? nil : Supplier.find(key[1]), Business.find(key[2]), current_storage)
      if orders_changed
        sum = orders.includes(:order_details).where(is_shortage: 'no').where(order_details: {specification_id: key[0], supplier_id: key[1]}, business_id: key[2], storage_id: current_storage.id).sum(:amount)
      end
      if stock_sum < sum
        orders_changed = true
        related_orders = orders.joins(:order_details).where(order_details: {specification_id: key[0], supplier_id: key[1]}, business_id: key[2], storage_id: current_storage.id)
        limit = sum - stock_sum
        offset_orders = related_orders.offset(related_orders.count - limit).readonly(false)
        offset_sum = offset_orders.includes(:order_details).sum(:amount)
        if offset_sum == limit
          offset_orders.update_all(is_shortage: 'yes')
        else
          offset_orders.each do |x|
            related_details = x.order_details.where(order_details: {specification_id: key[0], supplier_id: key[1]})
            tmp_sum = related_details.sum(:amount)
            x.update(is_shortage: 'yes')
            related_details.update_all(is_shortage: 'yes')
            limit = limit - tmp_sum
            if limit <= 0
              break
            end
          end
        end
        # order_array = []
        # x.each do |y|
        #   order_array << y.id
        # end
        # orders.delete_if {|item| !order_array.index(item.id).blank?}
      end
    end

    return_orders = nil

    if type.eql? '0'
      return_orders = orders.reload.where(is_shortage: 'no')
    else
      return_orders = orders.reload.where(is_shortage: 'yes')
    end

    if createKeyCilentOrderFlg
      if ordercnt > 0
        time = Time.new
        # batch_no = time.year.to_s+time.month.to_s.rjust(2,'0')+time.day.to_s.rjust(2,'0')+Keyclientorder.count.to_s.rjust(5,'0')
        @keycorder = Keyclientorder.create(keyclient_name: "auto",unit_id: current_user.unit_id,storage_id: current_storage.id,user: current_user,status: "waiting")
        return_orders.update_all(keyclientorder_id: @keycorder)

        allcnt = return_orders.includes(:order_details).where.not("order_details.specification_id" => nil, business_id: nil).group("orders.business_id", :specification_id, :supplier_id).sum(:amount)

        allcnt.each do |k,v|
          if v[1] > 0
            Keyclientorderdetail.create(keyclientorder: @keycorder,business_id: k[0],specification_id: k[1],supplier_id: k[2],amount: v)
          end
        end
      end
    end

    return return_orders.reload

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
