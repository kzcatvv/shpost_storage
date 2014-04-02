json.array!(@purchasedetails) do |purchasedetail|
  json.extract! purchasedetail, :id, :name, :purchase_id, :supplier_id, :spec_id, :qg_period, :batch_no, :amount, :sum, :desc, :status
  json.url purchasedetail_url(purchasedetail, format: :json)
end
