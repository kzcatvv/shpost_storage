class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :no,null:false, default: ''
      t.string :order_type
      t.string :need_invoice
      t.string :customer_name
      t.string :customer_unit
      t.string :customer_tel
      t.string :customer_phone
      t.string :customer_address
      t.string :customer_postcode
      t.string :customer_email
      t.float :total_weight
      t.float :total_price
      t.integer :total_amount
      t.string :transport_type
      t.float :transport_price
      t.string :pay_type
      t.string :status
      t.string :buyer_desc
      t.string :seller_desc
     

      t.timestamps
    end
  end
end
