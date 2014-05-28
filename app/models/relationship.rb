class Relationship < ActiveRecord::Base
  belongs_to :business
  belongs_to :supplier
  belongs_to :specification
  has_and_belongs_to_many :contacts
  validates_presence_of :business_id, :specification_id, :external_code, :message => '不能为空'

  def self.find_relationship(external_code, supplier = nil, spec_desc = nil, business, unit)
    conditions =  where(business_id: business, external_code: external_code)
    
    if !supplier.blank?
      conditions = conditions.where(supplier: supplier)
    end

    if !spec_desc.blank?
      conditions = conditions.where(spec_desc: spec_desc)
    end

    conditions.includes(:specification).includes(specification: :commodity).where(commodities: { unit_id: unit}).first
  end

  #def self.find_relationship(specification, business, unit)
    #conditions =  where(business_id: business, specification_id: specification)
    
    #conditions.includes(:specification).includes(specification: :commodity).where(commodities: { unit_id: unit}).first
  #end
end
