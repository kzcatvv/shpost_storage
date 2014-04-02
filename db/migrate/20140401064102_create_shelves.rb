class CreateShelves < ActiveRecord::Migration
  def change
    create_table :shelves do |t|
      t.integer :area_id
      t.string :shelf_code
      t.string :desc

      t.timestamps
    end
  end
end
