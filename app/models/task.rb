class Task < ActiveRecord::Base
  belongs_to :parent, polymorphic: true
  belongs_to :user
  belongs_to :storage
end
