# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :commodity do
    association :unit
    #association :goodstype
  	cno "test"
  	name "test"
  	goodstype_id 1

  	factory :new_commodity do
    	cno "new"
    	name "new"
        unit_id 1
        goodstype_id 1
    end

	factory :update_commodity do
    	cno "update"
  	    name "update"
    end


    factory :invalid_commodity do
    	cno nil
  	    name "invalid"
    end
  end
end
