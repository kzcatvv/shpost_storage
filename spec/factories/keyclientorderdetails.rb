# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :keyclientorderdetail do
    keyclientorder_id 1
    specification_id 1
    desc "MyString"
  end
end
