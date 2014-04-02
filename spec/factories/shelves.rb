# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :shelf do
    association :area
    shelf_code "shelf1"
    desc "shelf1_desc"
  end
end
