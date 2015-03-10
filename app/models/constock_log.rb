class ConstockLog < ActiveRecord::Base
	belongs_to :user
	belongs_to :consumable_stock

	OPERATION_TYPE_SHOW = {in: '入库', out: '出库'}
end
