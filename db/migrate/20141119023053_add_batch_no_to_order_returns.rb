class AddBatchNoToOrderReturns < ActiveRecord::Migration
  def change
  	add_column :order_returns, :batch_no, :string
  	remove_column :order_return_details, :batch_no
  end
end
