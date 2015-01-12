class AddSnToStocks < ActiveRecord::Migration
  def change
    add_column :stocks, :sn, :string
  end
end
