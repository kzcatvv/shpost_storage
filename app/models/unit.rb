class Unit < ActiveRecord::Base
  has_many :users
  has_many :storages
  validates :name, presence: true,
                    uniqueness: { case_sensitive: false }
end
