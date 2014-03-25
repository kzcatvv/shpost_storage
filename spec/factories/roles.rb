# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :role do
    user_id 3
    storage_id 1
    role "sorter"

    factory :new_role do
    	user_id 2
        storage_id 1
    end
  end
end
