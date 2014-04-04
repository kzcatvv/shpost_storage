class Purchase < ActiveRecord::Base
	belongs_to :unit
	belongs_to :bussiness
	has_many :purchase_detail, dependent: :destroy
	        
	STATUS = { no: '未处理', yes: '处理中', prepare: '发货' ,recevie: '已收货'}

	validates_presence_of :no, :message => '不能为空'


end

