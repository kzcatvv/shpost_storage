# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :order do
    sequence(:no) { |n| "no#{n}_test"}
    order_type "order_type"
    has_invoice "yes"
    cust_id "20140404001"
    cust_name "liuyingying"
    cust_phone "34124888"
    cust_mobilephone "123456"
    cust_address "xxxx"
    cust_postcode "201199"
    cust_email "anniliu.student@sina.com"
    good_weight 1.5
    good_sum 1.5
    good_amount 1
    trans_type "ems"
    trans_sum 1.5
    pay_type "paypal"
    status "prepare"
    buyer_desc "buyer_desc"
    seller_desc "seller_desc"

    factory :invalid_order do
        no nil
        good_sum 0
        good_amount 0 
    end

    factory :update_order do
        no "20140401001"
        good_amount 200
        good_sum 200.1
    end
  end
end

