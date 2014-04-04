class CreateOrderDetails < ActiveRecord::Migration
  def change
    create_table :order_details do |t|
      t.string :name,null:false, default: ''
      t.integer :specification_id
      t.integer :amount
      t.float :price
      t.string :batch_no
      t.integer :supplier_id
      t.integer :order_id
      t.string :desc

      t.timestamps
    end
  end
end
