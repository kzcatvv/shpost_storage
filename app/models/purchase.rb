class Purchase < ActiveRecord::Base
	belongs_to :unit
	belongs_to :business
	has_many :purchase_details, dependent: :destroy
	        
	STATUS = { untreated: '未处理', processing: '处理中', prepare: '发货' ,recevie: '已收货' ,processed: '处理完毕'}
 
	validates_presence_of :no, :message => '不能为空'

 def statusname
    Purchase::STATUS[status.to_sym]
  end

end

