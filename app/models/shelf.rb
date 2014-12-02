class Shelf < ActiveRecord::Base
	belongs_to :area
  has_one :storage, through: :area
  has_one :unit, through: :area
  has_many :stocks


	validates_presence_of :shelf_code, :area_id, :message => '不能为空字符'

	validates_numericality_of :max_weight, :max_volume, :only_integer => true, :message => '不是数字'
	# validates_numericality_of :area_length, :area_width, :area_height, :shelf_row, :shelf_column, :only_integer => true, :message => '不是数字'
	# validates_numericality_of :area_length, :area_width, :area_height, :shelf_row, :shelf_column, :greater_than => 0, :less_than => 100, :message => "超过最大值{99}"

  validates_uniqueness_of :shelf_code, scope: :area_id, :message => "货架已存在"
 
  scope :empty, ->{ includes(:stocks).where(stocks: {id: nil})}

  scope :prior, ->{ order("priority_level ASC")}

  scope :normal, ->{ where(is_bad: 'yes')}

  scope :broken, ->{ where(is_bad: 'no')}

  BAD_TYPE = { yes: '是', no: '否' }

  # def self.min_abs_pl(priority_level)
  #   condition = "abs(#{priority_level} - priority_level) "

  #   where(["#{condition} = ?", prior.minimum(condition)])
  #   else
  # end


  def self.in_storage(storage)
    Shelf.includes(:area).where(area_id: storage.areas).order("priority_level ASC")
  end

  def self.get_empty_shelf(storage, is_broken = false)
    # prior.first
    shelves = in_storage(storage).empty.prior
    if ! is_broken
      shelves.normal.first
    else
      shelves.broken.first
    end
  end

  def self.get_neighbor_shelf(stocks)
    return nil
    # Shelf.includes(:stocks).where(stocks: stocks).order("priority_level ASC").first
    # prior.first
  end
  
  def self.get_default_shelf(storage, is_broken = false)
    shelves = in_storage(storage).prior
    if ! is_broken
      shelves.normal.first
    else
      shelves.broken.first
    end
    # default.first
  end

  def bad_type_name
    is_bad.blank? ? "" : Shelf::BAD_TYPE["#{is_bad}".to_sym]
  end

  def is_available?
    true
  end
end
