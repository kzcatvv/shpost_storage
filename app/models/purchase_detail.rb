class PurchaseDetail < ActiveRecord::Base
	belongs_to :specification
	belongs_to :supplier
	belongs_to :purchase
	validates_presence_of :name, :message => '不能为空'

STATUS = { untreated: '未处理', processing: '处理中', prepare: '发货' ,recevie: '已收货' ,processed: '处理完毕'}
def statusname
    PurchaseDetail::STATUS[status.to_sym]
end


end
