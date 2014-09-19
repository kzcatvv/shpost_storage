class Keyclientorder < ActiveRecord::Base
  has_many :keyclientorderdetails, dependent: :destroy
  has_many :orders
  has_many :order_details, through: :orders
  has_many :stock_logs, through: :order_details
  belongs_to :unit
  belongs_to :storage
  belongs_to :business
  belongs_to :user

  before_validation :set_batch_id

  validates_presence_of :keyclient_name, :batch_id, :unit_id, :storage_id, :message => '不能为空'
  validates_uniqueness_of :batch_id, :message => '该订单批次编号已存在'

  def set_batch_id
    if self.batch_id.blank?
      time = Time.now
      self.batch_id = time.year.to_s + time.month.to_s.rjust(2,'0') + time.day.to_s.rjust(2,'0') + Keyclientorder.count.to_s.rjust(5,'0')
    end
  end


end
