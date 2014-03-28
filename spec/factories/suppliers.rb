# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :supplier do
  	association :unit
  	sno "test"
  	name "test"
  	address "test"
  	phone "test"

  	factory :new_supplier do
    	sno "new"
    	name "new"
  	    address "new"
  	    phone "new"
        unit_id 1
    end

	factory :update_supplier do
    	sno "update"
  	    name "update"
  	    address "update"
  	    phone "update"
    end


    factory :invalid_supplier do
    	sno nil
  	    name "invalid"
  	    address "invalid"
  	    phone "invalid"
    end
  end
end
