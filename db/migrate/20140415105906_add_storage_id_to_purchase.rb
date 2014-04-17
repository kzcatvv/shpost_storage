class AddStorageIdToPurchase < ActiveRecord::Migration
  def change
    add_column :purchases, :storage_id, :integer
  end
end
