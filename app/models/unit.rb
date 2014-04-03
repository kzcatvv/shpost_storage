class Unit < ActiveRecord::Base
  has_many :users, dependent: :destroy
  has_many :storages, dependent: :destroy
  has_many :suppliers, dependent: :destroy
  has_many :goodstypes, dependent: :destroy
  has_many :commodities, dependent: :destroy
  validates :name, presence: true,
                    uniqueness: { case_sensitive: false }
  validates_presence_of :name, :message => '不能为空字符'
  validates_uniqueness_of :name, :message => '该单位已存在'
end
