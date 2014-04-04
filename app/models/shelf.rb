class Shelf < ActiveRecord::Base
	belongs_to :area

	validates_presence_of :shelf_code, :area_id, :area_length, :area_width, :area_height, :shelf_row, :shelf_column, :message => '不能为空字符'

	validates_numericality_of :max_weight, :max_volume, :only_integer => true, :message => '不是数字'
	validates_numericality_of :area_length, :area_width, :area_height, :shelf_row, :shelf_column, :only_integer => true, :message => '不是数字'
	validates_numericality_of :area_length, :area_width, :area_height, :shelf_row, :shelf_column, :greater_than => 0, :less_than => 100

end
