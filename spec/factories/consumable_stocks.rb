# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :consumable_stock do
    consumable_id 1
    shelf_name "MyString"
    amount 1
  end
end
