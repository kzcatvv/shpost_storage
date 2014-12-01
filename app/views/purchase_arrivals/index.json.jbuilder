json.array!(@purchase_arrivals) do |purchase_arrivals|
  json.extract! purchase_arrivals, :id, :arrived_amount, :expiration_date, :arrived_at, :batch_no, :purchase_detail_id
  json.url purchase_arrivals_url(purchase_arrivals, format: :json)
end
