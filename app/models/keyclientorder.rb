class Keyclientorder < ActiveRecord::Base
  has_many :keyclientorderdetails, dependent: :destroy
  has_many :orders
  has_many :order_details, through: :orders
  has_many :stock_logs, as: :parent
  belongs_to :unit
  belongs_to :storage
  belongs_to :business
  belongs_to :user
  has_many :tasks, as: :parent
  has_many :user_logs, as: :parent

  # before_validation :set_batch_id

  validates_presence_of :keyclient_name, :unit_id, :storage_id, :message => '不能为空'

  STATUS = { waiting: 'waiting', printed: 'printed', picking: 'picking', checked: 'checked'}
  
  STATUS_SHOW = { waiting: '待处理', printed: '已打印', picking: '正在拣货', checked: '已审核'}
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

  def order_checked?
    self.orders.each do |x|
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
    if self.waiting_amounts.blank?
      self.orders.each do |order|
        order.stock_out
      end
    end
    if self.order_checked?
      self.update(status: STATUS[:checked])
    end
  end

  def pickcheck!    
    self.stock_logs.where(operation: 'b2c_stock_out').each do |x|
      x.check!
    end
    if self.pick_waiting_amounts.blank?
      self.orders.each do |order|
        order.stock_out
      end
    end
    if self.order_checked?
      self.update(status: STATUS[:checked])
    end
    self.stock_logs.where(operation_type: 'out').each do |sl|
      insl = sl.pick
      outsl = self.stock_logs.create(stock: insl.stock, user: insl.user, operation: StockLog::OPERATION[:b2c_pick_out], status: StockLog::STATUS[:waiting], amount: insl.amount, operation_type: StockLog::OPERATION_TYPE[:out])
    end
  end

  def pickoutcheck!(order)
    order.order_details.each do |od|
      @relationship=Relationship.where("business_id=? and supplier_id=? and specification_id=?",order.business_id,od.supplier_id,od.specification_id).first
      @stock_logs = self.stock_logs.where(operation: 'b2c_pick_out',relationship: @relationship)
      if @stock_logs.sum(:amount) == @stock_logs.sum(:check_amount)
        @stock_logs.each do |x|
          x.check!
        end
      end
    end
  end

  def waiting_amounts
    # sum_stock_logs = self.stock_logs.includes(:order_details).group("stock_logs.specification_id").group("stock_logs.supplier_id").group("stock_logs.business_id").group("order_details.defective").sum("stock_logs.amount")
    sum_stock_logs={}
    sum_stock_logs_hash = self.stock_logs.includes(:shelf).where("shelves.shelf_type = 'normal' or shelves.shelf_type is null or shelves.shelf_type = 'broken'").group("stock_logs.specification_id").group("stock_logs.supplier_id").group("stock_logs.business_id").group("shelves.shelf_type").order("stock_logs.specification_id,stock_logs.supplier_id,stock_logs.business_id").sum("stock_logs.amount")

    key_new=[]
    key_last=[]
    key_last[0] = ""
    key_last[1] = ""
    key_last[2] = ""
    sum_stock_logs_hash.each do |key,value|
      if key[3].eql?"broken"
        key_new=[key[0],key[1],key[2],"1"]
        sum_stock_logs[key_new]=value
      else
        key_new=[key[0],key[1],key[2],"0"]
        if key[0]==key_last[0] and key[1]==key_last[1] and key[2]==key_last[2]
          if sum_stock_logs[key_new].blank?
            sum_stock_logs[key_new] = value
          else
            sum_stock_logs[key_new]+=value
          end
        else
          sum_stock_logs[key_new]=value
        end
      end
      key_last=[key[0],key[1],key[2]]
    end

    
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

  def pick_waiting_amounts
    sum_stock_logs = self.stock_logs.where("operation_type='out' and operation='b2c_stock_out'").group(:specification_id, :supplier_id, :business_id).sum(:amount)
    sum_amount = self.details.group(:specification_id, :supplier_id, :business_id).sum(:amount)

    compare_sum_amount(sum_amount, sum_stock_logs)

    #compare without supplier
    if ! sum_amount.blank? && ! sum_stock_logs.blank?
      sum_stock_logs_without_supplier = {}
      sum_stock_logs.each do |x, amount|
        sum_stock_logs_without_supplier[[x[0], nil, x[2]]] = amount
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
