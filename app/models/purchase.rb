class Purchase < ActiveRecord::Base
	belongs_to :unit
	belongs_to :business
	has_many :purchase_details, dependent: :destroy
  has_many :stock_logs, through: :purchase_details
	        
<<<<<<< HEAD
	STATUS = { untreated: '未处理', processing: '处理中', prepare: '发货' ,recevie: '已收货' ,processed: '处理完毕'}
 
	validates_presence_of :no, :message => '不能为空'

 def statusname
    Purchase::STATUS[status.to_sym]
  end

=======
	STATUS = { opened: 'opened', closed: 'closed'}

	validates_presence_of :no, :name, message: '不能为空'
  validates_numericality_of :sum, allow_blank: true
  validates_numericality_of :amount, only_integer: true, allow_blank: true # 必須是整數

  def status_name
    status.blank? ? "" : self.class.human_attribute_name("status_#{status}")
  end
>>>>>>> 50716119104ecb16843c2c33a8c3af8fa1b59049
end

