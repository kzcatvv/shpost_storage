json.array!(@country_codes) do |country_code|
  json.extract! country_code, :id, :chinese_name, :english_name, :code, :surfmail_partition_no, :regimail_partition_no, :is_mail
  json.url country_code_url(country_code, format: :json)
end
