class Stock < ActiveRecord::Base
  belongs_to :specification
  belongs_to :shelf
  belongs_to :business
  belongs_to :supplier
  has_many :stock_logs

  validates_presence_of :specification_id, :actual_amount, :virtual_amount
end
