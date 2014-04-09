# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :stock_log do
    user_id 1
    stock_id 1
    operation "create_stock"
    operation_type StockLog::OPERATION_TYPE[:in]
    status StockLog::STATUS[:waiting]
    purchase_detail_id 1
    amount 10
  
    factory :checked_stock_log do
      status StockLog::STATUS[:checked]
      checked_at "2014-03-25 20:01:36"
    end
  end
end
