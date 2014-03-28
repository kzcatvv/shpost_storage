FactoryGirl.define do
  factory :storage do
  	name "storage1"
    desc "unit_desc"
    unit_id 1

    factory :new_storage do
    	name "new_storage"
        desc "new_desc"
        unit_id 1
    end
  end
end