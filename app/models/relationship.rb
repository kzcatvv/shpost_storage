class Relationship < ActiveRecord::Base
  belongs_to :business
  belongs_to :supplier
  belongs_to :specification
  has_one :unit, through: :specification
  has_and_belongs_to_many :contacts
  validates_presence_of :business_id, :specification_id, :message => '不能为空'

  after_save :change_external_code

  def self.find_relationships(business_sku, supplier = nil, spec_desc = nil, business = nil, unit)
    conditions =  where(external_code: business_sku)
    
    if !business.blank?
      conditions = conditions.where(business_id: business)
    end

    if !supplier.blank?
      conditions = conditions.where(supplier: supplier)
    end

    if !spec_desc.blank?
      conditions = conditions.where(spec_desc: spec_desc)
    end

    conditions.includes(:specification).includes(specification: :commodity).where(commodities: { unit_id: unit}).first
  end

  def self.find_relationship(specification, business, unit, supplier = nil)
    conditions =  where(business_id: business, specification_id: specification)

    if !supplier.blank?
      conditions = conditions.where(supplier: supplier)
    end
    
    conditions.includes(:specification).includes(specification: :commodity).where(commodities: { unit_id: unit}).first
  end

  def change_external_code
    if self.external_code.blank?
      self.external_code = self.barcode
      self.save
    end
  end
  # def self.find_relationships(sku, supplier = nil, spec_desc = nil,unit)

  #  conditions =  where(external_code: sku)
   
  #  if !supplier.blank?
  #    conditions = conditions.where(supplier: supplier)
  #  end

  #  if !spec_desc.blank?
  #    conditions = conditions.where(spec_desc: spec_desc)
  #  end

  #  conditions.includes(:specification).includes(specification: :commodity).where(commodities: { unit_id: unit}).first
  # end



end
