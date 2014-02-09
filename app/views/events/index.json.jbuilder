json.array!(@events) do |event|
  json.extract! event, :id, :name, :description, :is_public
  json.url event_url(event, format: :json)
end
