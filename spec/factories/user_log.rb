# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_log do
    user_id 1
    operation "login_in"
    object_class nil
  end

end
