class CreateStockMons < ActiveRecord::Migration
  def change
    create_table :stock_mons do |t|
      t.string :summ_date
      t.integer :storage_id
      t.integer :business_id
      t.integer :supplier_id
      t.integer :specification_id
      t.integer :amount

      t.timestamps
    end
  end
end
