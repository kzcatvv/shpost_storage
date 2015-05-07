json.array!(@sequence_nos) do |sequence_no|
  json.extract! sequence_no, :id, :unit_id, :storage_id, :logistic_id, :start_no, :end_no
  json.url sequence_no_url(sequence_no, format: :json)
end
