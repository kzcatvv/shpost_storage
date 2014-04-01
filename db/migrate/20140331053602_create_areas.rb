class CreateAreas < ActiveRecord::Migration
  def change
    create_table :areas do |t|
      t.integer :storage_id
      t.string :desc, :null => false, :default => ""
      t.string :are_code, :null => false, :default => ""

      t.timestamps
    end
  end
end
