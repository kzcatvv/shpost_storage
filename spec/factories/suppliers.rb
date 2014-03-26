# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :supplier do
  	association :unit
  	sno "test"
  	name "test"
  	address "test"
  	phone "test"
  end
end
