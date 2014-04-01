class Shelf < ActiveRecord::Base
	belongs_to :area

	validates_presence_of :shelf_code, :area_id, :message => '不能为空字符'

end
