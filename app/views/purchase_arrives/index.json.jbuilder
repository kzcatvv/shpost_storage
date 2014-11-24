json.array!(@purchase_arrives) do |purchase_arrife|
  json.extract! purchase_arrife, :id, :arrived_amount, :expiration_date, :date, :arrived_date, :date, :batch_no, :string, :purchase_detail_id, :integer
  json.url purchase_arrife_url(purchase_arrife, format: :json)
end
