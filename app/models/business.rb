class Business < ActiveRecord::Base
	belongs_to :unit
	validates_presence_of :name
  validates_uniqueness_of :no, scope: :unit_id,:message => "商户已存在"

end
