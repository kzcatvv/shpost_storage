json.array!(@storages) do |storage|
  json.extract! storage, :id, :name, :desc
  json.url storage_url(storage, format: :json)
end
