json.array!(@move_stocks) do |move_stock|
  json.extract! move_stock, :id, :no, :unit_id, :amount, :sum, :desc, :status, :name, :storage_id, :barcode
  json.url move_stock_url(move_stock, format: :json)
end
