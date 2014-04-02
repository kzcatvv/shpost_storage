class Shelf < ActiveRecord::Base
	belongs_to :area

	validates_presence_of :shelf_code, :area_id, :message => '不能为空字符'

	validates_numericality_of :max_weight, :max_volume, :only_integer => true, :message => '不是数字'
	validates_numericality_of :vertical, :horizontal, :shelf_row, :shelf_column, :only_integer => true, :message => '不是数字'
	validates_numericality_of :vertical, :horizontal, :shelf_row, :shelf_column, :greater_than => 0, :less_than => 100

end
