class CreateManualStockDetails < ActiveRecord::Migration
  def change
    create_table :manual_stock_details do |t|
      t.string :name
      t.string :desc
      t.string :status
      t.integer :amount
      t.integer :manual_stock_id
      t.integer :supplier_id
      t.integer :specification_id

      t.timestamps
    end
  end
end
