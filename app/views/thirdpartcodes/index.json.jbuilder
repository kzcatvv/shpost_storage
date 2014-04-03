json.array!(@thirdpartcodes) do |thirdpartcode|
  json.extract! thirdpartcode, :id, :business_id, :supplier_id, :specification_id, :sixnine_code, :external_code
  json.url thirdpartcode_url(thirdpartcode, format: :json)
end
