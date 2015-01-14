class MobileLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :storage
  belongs_to :unit
  belongs_to :mobile
end
