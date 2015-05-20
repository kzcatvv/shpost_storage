class AddDefectiveToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :defective, :string, :default => "0"
  end
end
