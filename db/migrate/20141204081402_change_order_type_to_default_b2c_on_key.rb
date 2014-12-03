class ChangeOrderTypeToDefaultB2cOnKey < ActiveRecord::Migration
  def change
  	change_column :keyclientorders, :order_type,:string,:default => "b2c"
  end
end
