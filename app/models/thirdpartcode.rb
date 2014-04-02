class Thirdpartcode < ActiveRecord::Base
  belongs_to :business
  belongs_to :supplier
  belongs_to :specification
  validates_presence_of :business_id, :supplier_id, :specification_id, :external_code, :message => '不能为空'
end
