json.array!(@storages) do |storage|
  json.extract! storage, :id, :name, :desc, :no
  json.url storage_url(storage, format: :json)
end
