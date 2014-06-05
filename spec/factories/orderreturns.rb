# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :orderreturn do
    order_detail_id 1
    return_reason "MyString"
    is_bad "MyString"
  end
end
