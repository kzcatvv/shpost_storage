json.array!(@shelves) do |shelf|
  json.extract! shelf, :id, :area_id, :shelf_code, :desc
  json.url shelf_url(shelf, format: :json)
end
