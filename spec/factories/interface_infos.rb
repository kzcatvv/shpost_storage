# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :interface_info do
    method_name "MyString"
    class_name "MyString"
    status "MyString"
    operate_time "MyString"
    url "MyString"
    url_method "MyString"
    url_content "MyText"
    type ""
  end
end
