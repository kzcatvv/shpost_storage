class Area < ActiveRecord::Base
	belongs_to :storage
	has_many :shelves, dependent: :destroy

	validates_presence_of :desc, :area_code, :storage_id, :message => '不能为空字符'
end
