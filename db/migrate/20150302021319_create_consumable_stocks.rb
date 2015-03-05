class CreateConsumableStocks < ActiveRecord::Migration
  def change
    create_table :consumable_stocks do |t|
      t.integer :consumable_id
      t.string :shelf_name
      t.integer :amount

      t.timestamps
    end
  end
end
