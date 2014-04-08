class PurchaseDetail < ActiveRecord::Base
	belongs_to :specification
	belongs_to :supplier
	belongs_to :purchase
  has_many :stock_logs, dependent: :destroy
	validates_presence_of :name, :amount, message: '不能为空'
  validates_numericality_of :sum, allow_blank: true
  validates_numericality_of :amount, only_integer: true # 必須是整數  

  STATUS = {waiting: 'waiting', stock_in: 'stock_in'}

  def status_name
    status.blank? ? "" : self.class.human_attribute_name("status_#{status}")
  end

  def waiting_amount
    self.amount - stock_logs.sum(:amount)
  end
end
