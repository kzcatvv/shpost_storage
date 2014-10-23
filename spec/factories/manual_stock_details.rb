# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :manual_stock_detail do
    name "MyString"
    desc "MyString"
    status "MyString"
    amount 1
    manual_stock_id 1
    supplier_id 1
    specification_id 1
  end
end
