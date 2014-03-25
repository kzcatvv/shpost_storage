# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :role do
    user_id 1
    storage_id 1
    role "MyString"
  end
end
