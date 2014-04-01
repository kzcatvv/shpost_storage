class CreatePurchases < ActiveRecord::Migration
  def change
    create_table :purchases do |t|
      t.string :no, null:false, default: ''
      t.integer :unit_id
      t.integer :business_id
      t.integer :amount
      t.float :sum
      t.string :desc
      t.string :status

      t.timestamps
    end
  end
end
