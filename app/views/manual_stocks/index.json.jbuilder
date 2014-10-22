json.array!(@manual_stocks) do |manual_stock|
  json.extract! manual_stock, :id, :no, :name, :desc, :status, :unit_id, :business_id, :storage_id
  json.url manual_stock_url(manual_stock, format: :json)
end
