json.array!(@keyclientorders) do |keyclientorder|
  json.extract! keyclientorder, :id, :keyclient_name, :keyclient_addr, :contact_person, :phone, :desc
  json.url keyclientorder_url(keyclientorder, format: :json)
end
