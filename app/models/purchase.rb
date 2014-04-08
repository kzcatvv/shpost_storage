class Purchase < ActiveRecord::Base
	belongs_to :unit
	belongs_to :business
	has_many :purchase_details, dependent: :destroy
  has_many :stock_logs, through: :purchase_details
	        
	STATUS = { opened: 'opened', closed: 'closed'}

	validates_presence_of :no, :name, message: '不能为空'
  validates_numericality_of :sum, allow_blank: true
  validates_numericality_of :amount, only_integer: true, allow_blank: true # 必須是整數

  def status_name
    status.blank? ? "" : self.class.human_attribute_name("status_#{status}")
  end
end

