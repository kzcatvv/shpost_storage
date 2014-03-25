class CreateStockLogs < ActiveRecord::Migration
  def change
    create_table :stock_logs do |t|
      t.integer :user_id
      t.integer :stock_id
      t.string :operation, :null => false, :default => ""
      t.string :status
      t.string :object_class
      t.integer :object_primary_key
      t.string :object_symbol
      t.integer :amount, :null => false, :default => 0

      t.datetime :checked_at

      t.timestamps
    end
  end
end
