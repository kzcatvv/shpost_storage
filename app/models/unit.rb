class Unit < ActiveRecord::Base
  has_many :users, dependent: :destroy
  has_many :storages, dependent: :destroy
  validates_presence_of :name, :message => '不能为空字符'
end
