# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :manual_stock do
    no "MyString"
    name "MyString"
    desc "MyString"
    status "MyString"
    unit_id 1
    business_id 1
    storage_id 1
  end
end
