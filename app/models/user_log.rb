class UserLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :parent, polymorphic: true
  has_and_belongs_to_many :orders
  

  validates_presence_of :user_id, :operation
end
