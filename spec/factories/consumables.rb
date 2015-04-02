# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :consumable do
    business_id 1
    supplier_id 1
    name "MyString"
    spec_desc "MyString"
  end
end
