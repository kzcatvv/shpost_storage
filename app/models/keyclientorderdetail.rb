class Keyclientorderdetail < ActiveRecord::Base
  belongs_to :keyclientorder
  belongs_to :specification
  belongs_to :supplier
  belongs_to :business
  validates_presence_of :keyclientorder_id, :specification_id, :message => '不能为空'
end
