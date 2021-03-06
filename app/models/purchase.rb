class Purchase < ActiveRecord::Base
	belongs_to :unit
	belongs_to :business
  belongs_to :storage
	has_many :purchase_details, dependent: :destroy
  has_many :purchase_arrivals, through: :purchase_details
  # has_many :stock_logs, through: :purchase_details
	has_many :stocks, through: :purchase_details  
  has_many :stock_logs, as: :parent
  has_many :tasks, as: :parent
  has_many :user_logs, as: :parent

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

    self.purchase_details.each do |detail|
      detail.stock_in
      # detail.purchase_arrivals.each do |arrival|
      #   arrival.check
      # end
    end
  end

  def can_close?
    all_checked? #&& closed?
  end

  def all_checked?
    self.purchase_details.each do |x|
      if ! x.all_checked?
        return false
      end
    end
    return true
  end

  def has_checked?
    self.purchase_details.each do |x|
      if x.has_checked?
        return true
      end
    end
    return false
  end

  def closed?
    self.status.eql? STATUS[:closed]
  end


  def stock_in_amount(purchase_detail)
    self.stock_logs.where(specification: purchase_detail.specification, supplier: purchase_detail.supplier, business: self.business, storage: storage).sum(:amount)
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

