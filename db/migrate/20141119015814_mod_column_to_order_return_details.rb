class ModColumnToOrderReturnDetails < ActiveRecord::Migration
  def change
  	remove_column :order_return_details, :integer
  	remove_column :order_return_details, :string
  	remove_column :order_return_details, :datetime
  	change_column :order_return_details, :order_return_id, :integer
  	change_column :order_return_details, :order_detail_id, :integer
  end
end
