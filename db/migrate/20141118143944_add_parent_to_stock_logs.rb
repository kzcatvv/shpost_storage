class AddParentToStockLogs < ActiveRecord::Migration
  def change
    # add_column :stock_logs, :parent_id, :integer
    # add_column :stock_logs, :parent_type, :string
    change_table :stock_logs do |t|
      t.references :parent, polymorphic: true
    end
  end
end
