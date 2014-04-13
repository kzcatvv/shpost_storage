class Thirdpartcode < ActiveRecord::Base
  belongs_to :business
  belongs_to :supplier
  belongs_to :specification
  validates_presence_of :business_id, :specification_id, :external_code, :message => '不能为空'

  def self.find_by_keywords(sku, business, unit, supplier = nil)
    conditions =  where(business_id: business, external_code: sku)
    
    if !supplier.blank?
      conditions = conditions.where(supplier: supplier)
    end

    conditions.includes(:specification).includes(specification: :commodity).where(commodities: { unit_id: unit}).first
  end
end
