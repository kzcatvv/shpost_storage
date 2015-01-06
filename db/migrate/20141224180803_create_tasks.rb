class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :title
      t.string :barcode
      t.string :type
      t.string :status
      t.string :code
      t.references :storage
      t.references :parent, polymorphic: true
      t.references :user
      t.timestamps
    end
  end
end
