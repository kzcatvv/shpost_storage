class CreateUnitSuppliers < ActiveRecord::Migration
  def change
    create_table :unit_suppliers do |t|

      t.timestamps
    end
  end
end
