class CreateConsumables < ActiveRecord::Migration
  def change
    create_table :consumables do |t|
      t.integer :business_id
      t.integer :supplier_id
      t.string :name
      t.string :spec_desc

      t.timestamps
    end
  end
end
