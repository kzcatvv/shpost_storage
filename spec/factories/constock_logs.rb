# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :constock_log do
    user_id 1
    consumable_stock_id 1
    amount 1
    operation_type "MyString"
  end
end
