json.array!(@order_details) do |order_detail|
  json.extract! order_detail, :id, :name, :specification_id, :amount, :price, :batch_no, :supplier_id, :order_id, :desc
  json.url order_detail_url(order_detail, format: :json)
end
