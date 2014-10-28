class ChangeOrderreturnsToOrderReturns < ActiveRecord::Migration
  def change
    rename_table :orderreturns, :order_returns
  end
end
