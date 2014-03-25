json.array!(@goodstypes) do |goodstype|
  json.extract! goodstype, :id, :gtno, :name
  json.url goodstype_url(goodstype, format: :json)
end
