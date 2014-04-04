# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :order_detail do
    name "food"
    specification_id 1
    amount 1
    price 1.5
    batch_no "20140404001"
    supplier_id 1
    order_id 1
    desc "MyString"

    factory :invalid_order_detail do
        name nil
        price 0
        amount 0 
    end

    factory :update_order_detail do
        name "20140401001"
        amount 200
        price 200.1
    end
  end
end
