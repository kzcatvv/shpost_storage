# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    association :unit
    email "user@example.com"
    password "11111111"
    sequence(:username) { |n| "username#{n}_test"}
    name "name"
    role "user"

    factory :new_user do
    	email "new_user@example.com"
    	username "new_username_test"
    	name "new_name"
        unit_id 1
    end

	factory :update_user do
    	email "update_user@example.com"
    	username "update_username_test"
    	name "update_name"
    end

    factory :superadmin do
    	email "superadmin@example.com"
    	username "superadmin_test"
    	name "superadmin_name"
    	role "superadmin"
    end

    factory :unitadmin do
    	email "unitadmin@example.com"
    	username "unitadmin_test"
    	name "unitadmin_name"
    	role "unitadmin"
    end

    factory :invalid_user do
    	username nil
    	name "invalid_n"
    end
  end
end
