# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :unit do
  	sequence(:name) { |n| "unit_name#{n}_test"}
    desc "unit_desc"
  end
end
