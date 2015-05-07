class AddSendColoumnsToOrdersForWish < ActiveRecord::Migration
  def change
    add_column :orders, :send_addr, :string
    add_column :orders, :send_name, :string
    add_column :orders, :send_zip, :string
    add_column :orders, :send_mobile, :string
  end
end
