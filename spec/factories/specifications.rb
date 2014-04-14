# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :specification do
    commodity_id 1
    name "specificationname"
    sixnine_code "1234"
    product_no "201401"
  end
end
