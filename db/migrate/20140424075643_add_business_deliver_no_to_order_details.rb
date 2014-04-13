class AddBusinessDeliverNoToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :business_deliver_no, :string
  end
end
