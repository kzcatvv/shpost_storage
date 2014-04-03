json.array!(@purchase_details) do |purchase_detail|
  json.extract! purchase_detail, :id, :name, :purchase_id, :supplier_id, :spec_id, :qg_period, :batch_no, :amount, :sum, :desc, :status
  json.url purchase_detail_url(purchase_detail, format: :json)
end
