class CreateInventories < ActiveRecord::Migration
  def change
    create_table :inventories do |t|
      t.string :no
      t.integer :unit_id
      t.string :desc
      t.string :name
      t.string :type
      t.integer :storage_id
      t.string :barcode

      t.timestamps
    end
  end
end
