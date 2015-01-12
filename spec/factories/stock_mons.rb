# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :stock_mon do
    summ_date "MyString"
    storage_id 1
    business_id 1
    supplier_id 1
    specification_id 1
    amount 1
  end
end
