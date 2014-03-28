class CreateSpecifications < ActiveRecord::Migration
  def change
    create_table :specifications do |t|
      t.integer :commodity_id
      t.string :model
      t.string :size
      t.string :color

      t.timestamps
    end
  end
end
