json.array!(@keyclientorderdetails) do |keyclientorderdetail|
  json.extract! keyclientorderdetail, :id, :keyclientorder_id, :specification_id, :desc
  json.url keyclientorderdetail_url(keyclientorderdetail, format: :json)
end
