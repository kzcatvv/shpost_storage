class Business < ActiveRecord::Base
	belongs_to :unit
	validates_presence_of :name
  has_many :relationships, dependent: :destroy
end
