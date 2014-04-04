class Purchase < ActiveRecord::Base
	belongs_to :unit
<<<<<<< HEAD
	belongs_to :business
	has_many :purchase_details, dependent: :destroy
=======
	belongs_to :bussiness
	has_many :purchase_detail, dependent: :destroy
	        
	STATUS = { no: '未处理', yes: '处理中', prepare: '发货' ,recevie: '已收货'}

>>>>>>> 287e466e0f44208b0be2cccf71ce74c764e22328
	validates_presence_of :no, :message => '不能为空'


end

