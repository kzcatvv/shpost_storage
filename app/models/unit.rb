class Unit < ActiveRecord::Base
  has_many :users, dependent: :destroy
  has_many :storages, dependent: :destroy
  validates :name, presence: true,
                    uniqueness: { case_sensitive: false }
end
