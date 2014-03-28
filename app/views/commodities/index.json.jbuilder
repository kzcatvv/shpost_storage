json.array!(@commodities) do |commodity|
  json.extract! commodity, :id, :cno, :name, :goodstype_id
  json.url commodity_url(commodity, format: :json)
end
