# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :move_stock do
    no "MyString"
    unit_id 1
    amount 1
    sum 1.5
    desc "MyString"
    status "MyString"
    name "MyString"
    storage_id 1
    barcode "MyString"
  end
end
