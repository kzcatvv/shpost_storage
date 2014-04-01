json.array!(@purchases) do |purchase|
  json.extract! purchase, :id, :no,  :unit_id, :business_id, :amount, :sum, :desc, :status
  json.url purchase_url(purchase, format: :json)
end
