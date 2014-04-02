class CreateStocks < ActiveRecord::Migration
  def change
    create_table :stocks do |t|
      t.integer :shelf_id
      t.integer :business_id
      t.integer :supplier_id
      t.string :batch_no
      t.integer :specification_id, null: false
      t.integer :actual_amount, null: false, default: 0
      t.integer :virtual_amount, null: false, default: 0
      t.string :desc

      t.timestamps
    end
  end
end
