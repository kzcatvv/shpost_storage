class Keyclientorder < ActiveRecord::Base
  has_many :keyclientorderdetails, dependent: :destroy
  validates_presence_of :keyclient_name, :batch_id, :message => '不能为空'
  validates_uniqueness_of :batch_id, :message => '该订单批次编号已存在'
end