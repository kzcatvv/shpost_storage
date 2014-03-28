json.array!(@specifications) do |specification|
  json.extract! specification, :id, :commodity_id, :model, :size, :color
  json.url specification_url(specification, format: :json)
end
