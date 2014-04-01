# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :stock do
    shelf_id 1
    business_id 1
    supplier_id 1
    sequence(:batch_no) { |n| n}
    specification_id 1
    actual_amount 20
    virtual_amount 20

    factory :invalid_without_aa_stock do
      actual_amount nil
      virtual_amount 40
    end

    factory :invalid_without_va_stock do
      virtual_amount nil
    end

    factory :invalid_without_specification_stock do
      specification_id nil
    end

    factory :update_stock do
      actual_amount 40
      virtual_amount 50
    end
  end
end
