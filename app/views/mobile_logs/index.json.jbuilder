json.array!(@mobile_logs) do |mobile_log|
  json.extract! mobile_log, :id
  json.url mobile_log_url(mobile_log, format: :json)
end
