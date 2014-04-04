# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :shelf do
    association :area
    shelf_code "shelf1"
    area_length 1
    area_width 1
    area_height 1
    shelf_row 1
    shelf_column 1
    max_weight 100
    max_volume 130
    desc "shelf1_desc"
  end
end
