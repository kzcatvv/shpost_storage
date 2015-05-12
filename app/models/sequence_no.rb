class SequenceNo < ActiveRecord::Base
  validates_presence_of :unit_id, :storage_id, :logistic_id, :start_no, :end_no, :message => '不能为空字符'
end