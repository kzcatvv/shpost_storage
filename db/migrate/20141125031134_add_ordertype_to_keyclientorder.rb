class AddOrdertypeToKeyclientorder < ActiveRecord::Migration
  def change
  	add_column :keyclientorders, :order_type, :string
  end
end
