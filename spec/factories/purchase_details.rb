# Read about factories at https://github.com/thoughtbot/factory_girl


FactoryGirl.define do
  factory :purchase_detail do
    sequence(:name) { |n| "name#{n}_test"}
    purchase_id 1
    supplier_id 1
    specification_id 1
    qg_period  "180 day"
    sequence(:batch_no) { |n| "20140402001#{n}"}
    # batch_no   "20140402001"
    amount 100
    sum 100.1
    desc "liuyingying company"
    status PurchaseDetail::STATUS[:waiting]

    factory :invalid_purchase_detail do
        name nil
        amount 0 
    end

    factory :update_purchase_detail do
        name "stamp"
        amount 200
        sum 200.1
    end
  end
end