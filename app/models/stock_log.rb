class StockLog < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :operation, :amount
end
