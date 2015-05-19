class AddIsPrintedToOrders < ActiveRecord::Migration
  def change
  	add_column :orders, :is_printed, :boolean, default: false

  	Order.where.not(status: ['waiting','spliting','splited']).update_all(is_printed: true)
  end
end
