class PurchaseDetail < ActiveRecord::Base
	belongs_to :specification
	belongs_to :supplier
	belongs_to :purchase
<<<<<<< HEAD
	validates_presence_of :name, :message => '不能为空'

STATUS = { untreated: '未处理', processing: '处理中', prepare: '发货' ,recevie: '已收货' ,processed: '处理完毕'}
def statusname
    PurchaseDetail::STATUS[status.to_sym]
end


=======
  has_many :stock_logs, -> { where(object_class: 'PurchaseDetail') }, foreign_key: :object_primary_key, dependent: :destroy
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
>>>>>>> 50716119104ecb16843c2c33a8c3af8fa1b59049
end
