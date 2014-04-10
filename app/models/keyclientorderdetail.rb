class Keyclientorderdetail < ActiveRecord::Base
  belongs_to :keyclientorder
  belongs_to :specification
  belongs_to :supplier
  validates_presence_of :keyclientorder_id, :specification_id, :message => '不能为空'
  validates_uniqueness_of :specification_id, :scope => :keyclientorder_id, :message => '该订单已存在'
end
