# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :logistic do
    name "MyString"
    print_format "MyString"
    is_getnum false
    contact "MyString"
    address "MyString"
    contact_phone "MyString"
    post "MyString"
    is_default false
  end
end
