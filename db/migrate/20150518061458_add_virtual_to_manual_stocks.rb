class AddVirtualToManualStocks < ActiveRecord::Migration
  def change
    add_column :manual_stocks, :virtual, :string, :default => "0"
  end
end
