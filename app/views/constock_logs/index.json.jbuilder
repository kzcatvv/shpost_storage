json.array!(@stock_logs) do |stock_log|
  json.extract! stock_log, :id, :user_id, :stock_id, :type, :status, :check_at, :object_class, :object_id, :object_symbol
  json.url stock_log_url(stock_log, format: :json)
end
