class AddIsPrintedToOrders < ActiveRecord::Migration
  def change
  	add_column :orders, :is_printed, :boolean, default: false

  	orders = Order.all
    orders.each do |o|
      if o.status.eql?('waiting') || o.status.eql?('spliting') || o.status.eql?('splited')
        next
      else
    	o.update(is_printed: true)
      end
    end
  end
end
