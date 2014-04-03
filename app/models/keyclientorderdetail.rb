class Keyclientorderdetail < ActiveRecord::Base
  belongs_to :keyclientorder
  belongs_to :specification
  validates_presence_of :keyclientorder_id, :specification_id, :message => '不能为空'

end
