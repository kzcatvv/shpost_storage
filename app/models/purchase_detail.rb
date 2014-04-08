class PurchaseDetail < ActiveRecord::Base
	belongs_to :specification
	belongs_to :supplier
	belongs_to :purchase
  has_many :stock_logs, foreign_key: :object_primary_key, dependent: :destroy
	validates_presence_of :name, :amount, message: '不能为空'
  validates_numericality_of :sum, allow_blank: true
  validates_numericality_of :amount, only_integer: true # 必須是整數  
end
