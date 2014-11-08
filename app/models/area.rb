class Area < ActiveRecord::Base
	belongs_to :storage
  has_one :unit, through: :storage
	has_many :shelves, dependent: :destroy

	validates_presence_of :name, :area_code, :storage_id, :message => '不能为空字符'


	BAD_TYPE = { yes: '是', no: '否' }

	def bad_type_name
      is_bad.blank? ? "" : Area::BAD_TYPE["#{is_bad}".to_sym]
    end

  

end
