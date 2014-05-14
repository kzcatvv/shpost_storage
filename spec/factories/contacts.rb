# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :contact do
    name "MyString"
    email "MyString"
    phone "MyString"
    desc "MyString"
    supplier_id 1
  end
end
