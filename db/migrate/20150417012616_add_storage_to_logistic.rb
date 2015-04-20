class AddStorageToLogistic < ActiveRecord::Migration
  def change
  	add_column :logistics, :storage_id, :integer
  	add_column :logistics, :unit_id, :integer
  end
end
