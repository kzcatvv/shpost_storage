# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :area do
    association :storage
    name "name"
    desc "desc"
    area_code "area_code"

    factory :new_area do
        name "new_name"
    	desc "new_desc"
    	area_code "new_area_code"
    end

    factory :update_area do
    	desc "update_desc"
    	area_code "update_area_code"
    end

    factory :invalid_area do
    	name nil
    	area_code "invalid_a"
    end
  end
end
