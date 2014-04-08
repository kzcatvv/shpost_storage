class Purchase < ActiveRecord::Base
	belongs_to :unit
	belongs_to :business
	has_many :purchase_details, dependent: :destroy
	        
	STATUS = { waiting: 'waiting', done: 'done'}

	validates_presence_of [:no, :name], :message: '不能为空'
  validates_numericality_of :sum, allow_blank: true
  validates_numericality_of :amount, only_integer: true, allow_blank: true # 必須是整數  
end

