class CreateConstockLogs < ActiveRecord::Migration
  def change
    create_table :constock_logs do |t|
      t.integer :user_id
      t.integer :consumable_stock_id
      t.integer :amount
      t.string :operation_type

      t.timestamps
    end
  end
end
