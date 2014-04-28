json.array!(@relationships) do |relationship|
  json.extract! relationship, :id, :business_id, :supplier_id, :specification_id, :sixnine_code, :external_code, :spec_desc
  json.url relationship_url(relationship, format: :json)
end
