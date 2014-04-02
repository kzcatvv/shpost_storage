json.array!(@stocks) do |stock|
  json.extract! stock, :id, :shelf_id, :business_id, :supplier_id, :purchase_detail_id, :specification_id, :actual_amount, :virtual_amount
  json.url stock_url(stock, format: :json)
end
