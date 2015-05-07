class Supplier < ActiveRecord::Base
	belongs_to :unit
  belongs_to :business
	has_many :contacts, dependent: :destroy
  has_many :relationships
  
	# validates_presence_of :no, :name, :message => '不能为空'
	# validates_uniqueness_of :no, :message => '该编号已存在'

  # def self.find_supplier(supplier_no, business)
  #   find_by(no: business.no + '_' + supplier_no)
  # end

  # def self.create_supplier!(supplier_no, business, unit)
  #   create!(no: business.no + '_' + supplier_no, name: business.name + '_' + supplier_no, unit: unit)
  # end
end
