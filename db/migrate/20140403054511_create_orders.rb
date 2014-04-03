class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :no,null:false, default: ''
      t.string :order_type
      t.string :has_invoice
      t.string :cust_id
      t.string :cust_name
      t.string :cust_phone
      t.string :cust_mobilephone
      t.string :cust_address
      t.string :cust_postcode
      t.string :cust_email
      t.float :good_weight
      t.float :good_sum
      t.integer :good_amount
      t.string :trans_type
      t.float :trans_sum
      t.string :pay_type
      t.string :status
      t.string :buyer_desc
      t.string :seller_desc

      t.timestamps
    end
  end
end
