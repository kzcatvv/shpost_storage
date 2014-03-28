# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :goodstype do
  	association :unit
  	gtno "test"
  	name "test"

  	factory :new_goodstype do
    	gtno "new"
    	name "new"
        unit_id 1
    end

	factory :update_goodstype do
    	gtno "update"
  	    name "update"
    end


    factory :invalid_goodstype do
    	gtno nil
  	    name "invalid"
    end
  end
end
