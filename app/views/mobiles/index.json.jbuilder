json.array!(@mobiles) do |mobile|
  json.extract! mobile, :id
  json.url mobile_url(mobile, format: :json)
end
