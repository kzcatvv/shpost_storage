# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :thirdpartcode do
    business_id 1
    supplier_id 1
    specification_id 1
    sixnine_code "MyString"
    external_code "MyString"
  end
end
