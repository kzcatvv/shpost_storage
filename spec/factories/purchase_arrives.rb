# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :purchase_arrife, :class => 'PurchaseArrive' do
    arrived_amount 1
    expiration_date "MyString"
    date "MyString"
    arrived_date "MyString"
    date "MyString"
    batch_no "MyString"
    string "MyString"
    purchase_detail_id "MyString"
    integer "MyString"
  end
end
