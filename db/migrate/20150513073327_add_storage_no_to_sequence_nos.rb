class AddStorageNoToSequenceNos < ActiveRecord::Migration
  def change
    add_column :sequence_nos, :storage_no, :string
    change_column :sequence_nos, :start_no, :integer
    change_column :sequence_nos, :end_no, :integer
  end
end
