json.array!(@order_returns) do |order_return|
  json.extract! order_return, :id, :order_detail_id, :return_reason, :is_bad
  json.url order_return_url(order_return, format: :json)
end
