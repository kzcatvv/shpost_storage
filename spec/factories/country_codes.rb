# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :country_code do
    chinese_name "MyString"
    english_name "MyString"
    code "MyString"
    surfmail_partition_no "MyString"
    regimail_partition_no "MyString"
    is_mail false
  end
end
