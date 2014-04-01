class Area < ActiveRecord::Base
	belongs_to :storage

	validates_presence_of :desc, :area_code, :message => '不能为空字符'
end
