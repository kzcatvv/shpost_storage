# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :stock_log do
    user_id 1
    stock_id 1
    operation "create_stock"
    operation_type "in"
    status "waiting"
    checked_at "2014-03-25 20:01:36"
    object_class "Purchase"
    object_primary_key 1
    amount 10
    object_symbol "purchase_no"
  end
end
