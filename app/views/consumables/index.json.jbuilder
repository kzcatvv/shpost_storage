json.array!(@consumables) do |consumable|
  json.extract! consumable, :id, :business_id, :supplier_id, :name, :spec_desc
  json.url consumable_url(consumable, format: :json)
end
