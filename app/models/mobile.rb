class Mobile < ActiveRecord::Base
  belongs_to :user
  belongs_to :storage

  def is_use?
    user.blank? ? false : true
  end
end
