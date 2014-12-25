class Task < ActiveRecord::Base
  belongs_to :parent, polymorphic: true
  belongs_to :user
  belongs_to :storage

  validates_uniqueness_of :barcode, :code

  STATUS = {doing: 'doing', done: 'done'}
end
