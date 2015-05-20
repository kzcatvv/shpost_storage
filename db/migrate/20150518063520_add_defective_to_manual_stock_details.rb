class AddDefectiveToManualStockDetails < ActiveRecord::Migration
  def change
    add_column :manual_stock_details, :defective, :string, :default => "0"
  end
end
