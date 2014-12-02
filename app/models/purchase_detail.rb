class PurchaseDetail < ActiveRecord::Base
	belongs_to :specification
	belongs_to :supplier
	belongs_to :purchase
  has_one :unit, through: :purchase
  has_many :stock_logs, dependent: :destroy
  has_many :purchase_arrivals, dependent: :destroy

  # before_validation :set_batch_no

	validates_presence_of :name, :amount, message: '不能为空'
  validates_numericality_of :sum, allow_blank: true
  validates_numericality_of :amount, only_integer: true # 必須是整數  

  STATUS = {waiting: 'waiting', stock_in: 'stock_in'}

  def status_name
    status.blank? ? "" : self.class.human_attribute_name("status_#{status}")
  end

  def stock_in?
    self.status.eql? STATUS[:stock_in]
  end

  def waiting_amount
    self.purchase_arrivals.sum(:arrived_amount) - self.checked_amount
  end

  def stock_in
    if self.all_checked?
      self.update(status: STATUS[:stock_in])
    else
      false
    end
  end

  def all_checked?
    self.purchase_arrivals.sum(:arrived_amount).eql? self.checked_amount
  end

  def checked_amount
    self.purchase.stock_logs.where(business_id: self.purchase.business_id, supplier_id: self.supplier_id, specification_id: self.specification_id).to_a.sum{|x| x.checked? ? x.amount : 0}
  end

  # def set_batch_no
  #   if self.batch_no.blank?
  #     time = Time.now
  #     self.batch_no = time.year.to_s + time.month.to_s.rjust(2,'0') + time.day.to_s.rjust(2,'0') + PurchaseDetail.count.to_s.rjust(5,'0')
  #   end
  # end
end
