json.array!(@manual_stock_details) do |manual_stock_detail|
  json.extract! manual_stock_detail, :id, :name, :desc, :status, :amount, :manual_stock_id, :supplier_id, :specification_id
  json.url manual_stock_detail_url(manual_stock_detail, format: :json)
end
