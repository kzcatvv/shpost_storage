class Order < ActiveRecord::Base
  belongs_to :bussiness
	belongs_to :unit
	belongs_to :storage
  belongs_to :keyclientorder

	  has_many :order_detail, dependent: :destroy
		validates_presence_of :no, :message => '不能为空'
end
