class SequenceNo < ActiveRecord::Base
  validates :unit_id, :storage_id, :logistic_id, :start_no, :end_no, presence: true
end