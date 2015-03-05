json.array!(@consumable_stocks) do |consumable_stock|
  json.extract! consumable_stock, :id, :consumable_id, :shelf_name, :amount
  json.url consumable_stock_url(consumable_stock, format: :json)
end
