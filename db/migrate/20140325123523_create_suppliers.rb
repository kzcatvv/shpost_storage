class CreateSuppliers < ActiveRecord::Migration
  def change
    create_table :suppliers do |t|
    	t.string :sno
    	t.string :name
    	t.string :address
    	t.string :phone
    	t.integer :unit_id
    	t.timestamps
    end
  end
end
