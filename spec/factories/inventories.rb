# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :inventory do
    no "MyString"
    unit_id 1
    desc "MyString"
    name "MyString"
    type ""
    storage_id 1
    barcode "MyString"
  end
end
