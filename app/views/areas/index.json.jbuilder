json.array!(@areas) do |area|
  json.extract! area, :id, :storage_id, :desc, :are_code
  json.url area_url(area, format: :json)
end
