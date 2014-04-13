class AddBusinessTransNoToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :business_trans_no, :string
  end
end
