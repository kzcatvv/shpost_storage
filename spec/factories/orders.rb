# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :order do
    sequence(:no) { |n| "no#{n}_test"}
    order_type "order_type"
    need_invoice "yes"
    customer_name "liuyingying"
    customer_unit "shanghai post"
    customer_tel "34124888"
    customer_phone "123456"
    customer_address "xxxx"
    customer_postcode "201199"
    customer_email "anniliu.student@sina.com"
    total_weight 1.5
    total_price 1.5
    total_amount 1
    transport_type "ems"
    transport_price 1.5
    pay_type "paypal"
    status "prepare"
    buyer_desc "buyer_desc"
    seller_desc "seller_desc"
    business_id 1
    unit_id 1
    storage_id 1
    keyclientorder_id 1

    factory :invalid_order do
        no nil
        total_sum 0
        total_amount 0 
    end

    factory :update_order do
        no "20140401001"
        total_amount 200
        total_sum 200.1
    end
  end
end

