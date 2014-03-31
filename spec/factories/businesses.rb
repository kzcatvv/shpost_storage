# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :business do
    sequence(:name) { |n| "business#{n}_test"}
    email "business@163.com"
    contactor "liuyingying"
    phone "1234423232"
    address "my address"
    desc "desc"
    unit_id 1

    factory :invalid_business do
        name nil
        email "invalid@example.com"
        contactor "invalid"
    end

    factory :update_business do
        name "update_name"
    		email "update_business@example.com"
    end
  end
end
