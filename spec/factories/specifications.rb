# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :specification do
    commodity_id 1
    model "MyString"
    size "MyString"
    color "MyString"
  end
end
