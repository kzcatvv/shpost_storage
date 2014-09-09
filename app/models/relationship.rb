class Relationship < ActiveRecord::Base
  belongs_to :business
  belongs_to :supplier
  belongs_to :specification
  has_and_belongs_to_many :contacts
  validates_presence_of :business_id, :specification_id, :external_code, :message => '不能为空'

  def self.find_relationships(sku, supplier = nil, spec_desc = nil, business = nil, unit)
    conditions =  where(external_code: sku)
    
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

  def self.find_relationship(specification, business, unit)
    conditions =  where(business_id: business, specification_id: specification)
    
    conditions.includes(:specification).includes(specification: :commodity).where(commodities: { unit_id: unit}).first
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
