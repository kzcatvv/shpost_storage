json.array!(@logistics) do |logistic|
  json.extract! logistic, :id, :name, :print_format, :is_getnum, :contact, :address, :contact_phone, :post, :is_default
  json.url logistic_url(logistic, format: :json)
end
