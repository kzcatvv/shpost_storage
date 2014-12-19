class CreateMoveStocks < ActiveRecord::Migration
  def change
    create_table :move_stocks do |t|
      t.string :no
      t.integer :unit_id
      t.integer :amount
      t.float :sum
      t.string :desc
      t.string :status
      t.string :name
      t.integer :storage_id
      t.string :barcode

      t.timestamps
    end
  end
end
