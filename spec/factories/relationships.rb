# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :relationship do
    business_id 1
    supplier_id 1
    specification_id 1
    sixnine_code "MyString"
    external_code "MyString"
    spec_desc "spec"
  end
end
