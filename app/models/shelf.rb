class Shelf < ActiveRecord::Base
	belongs_to :area
  has_many :stocks

	validates_presence_of :shelf_code, :area_id, :message => '不能为空字符'

	validates_numericality_of :max_weight, :max_volume, :only_integer => true, :message => '不是数字'
	# validates_numericality_of :area_length, :area_width, :area_height, :shelf_row, :shelf_column, :only_integer => true, :message => '不是数字'
	# validates_numericality_of :area_length, :area_width, :area_height, :shelf_row, :shelf_column, :greater_than => 0, :less_than => 100, :message => "超过最大值{99}"

  validates_uniqueness_of :shelf_code, scope: :area_id, :message => "货架已存在"
 
  scope :prior, ->{ includes(:stocks).where(stocks: {id: nil}).order("priority_level ASC")}
  scope :default, ->{ includes(:stocks).order("priority_level ASC")}

  # def self.min_abs_pl(priority_level)
  #   condition = "abs(#{priority_level} - priority_level) "

  #   where(["#{condition} = ?", prior.minimum(condition)])
  #   else
  # end

  def self.get_empty_shelf
    prior.first
  end

  def self.get_neighbor_shelf(stocks)
    prior.first
  end
  
  def self.get_default_shelf
    default.first
  end
end
