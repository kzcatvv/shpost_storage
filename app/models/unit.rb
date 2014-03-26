class Unit < ActiveRecord::Base
  has_many :users, dependent: :destroy
  has_many :storages, dependent: :destroy
  has_many :suppliers
  has_many :goodstypes
  validates :name, presence: true,
                    uniqueness: { case_sensitive: false }
  validates_presence_of :name, :message => '不能为空字符'
end
