json.array!(@up_downloads) do |up_download|
  json.extract! up_download, :id, :name, :use, :desc, :ver_no, :url, :oper_date
  json.url up_download_url(up_download, format: :json)
end
