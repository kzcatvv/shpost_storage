json.array!(@interface_infos) do |interface_info|
  json.extract! interface_info, :id, :method_name, :class_name, :status, :operate_time, :url, :url_method, :url_content, :type
  json.url interface_info_url(interface_info, format: :json)
end
