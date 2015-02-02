json.array!(@inventories) do |inventory|
  json.extract! inventory, :id, :no, :unit_id, :desc, :name, :type, :storage_id, :barcode
  json.url inventory_url(inventory, format: :json)
end
