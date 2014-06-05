json.array!(@orderreturns) do |orderreturn|
  json.extract! orderreturn, :id, :order_detail_id, :return_reason, :is_bad
  json.url orderreturn_url(orderreturn, format: :json)
end
