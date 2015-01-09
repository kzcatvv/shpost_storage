class Task < ActiveRecord::Base
  belongs_to :parent, polymorphic: true
  belongs_to :user
  belongs_to :storage
  has_one :unit, through: :storage

  validates_uniqueness_of :barcode, :code

  STATUS = {doing: 'doing', done: 'done'}

  def done?
    (status.eql? Task::STATUS[:done]) ? true : false
  end
end
