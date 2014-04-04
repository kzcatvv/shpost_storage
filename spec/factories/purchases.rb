
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :purchase do
    sequence(:no) { |n| "no#{n}_test"}
    #date "2008-04-01 08:10:01"
    unit_id 1
    business_id 1
    amount 100
    sum 100.1
    desc "liuyingying company"
    status "1"

    factory :invalid_purchase do
        no nil
        sum 0
        amount 0 
    end

    factory :update_no do
        no "20140401001"
        amount 200
        sum 200.1
    end
  end
end
