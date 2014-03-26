# Read about factories at https://github.com/thoughtbot/factory_girl


FactoryGirl.define do
  factory :purchasedetail do
    sequence(:name) { |n| "name#{n}_test"}
    purchase_id 1
    supplier_id 1
    spec_id 1
    qg_period  "180 day"
    batch_no   "20140402001"
    amount 100
    sum 100.1
    desc "liuyingying company"
    status "1"

    factory :invalid_purchasedetail do
        name nil
        amount 0 
    end

    factory :update_purchasedetail do
        name "stamp"
        amount 200
        sum 200.1
    end
  end
end