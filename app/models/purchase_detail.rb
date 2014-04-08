class PurchaseDetail < ActiveRecord::Base
	belongs_to :specification
	belongs_to :supplier
	belongs_to :purchase
  has_many :stock_logs, foreign_key: , dependent: :destroy
	validates_presence_of :name, :message => '不能为空'
end
