class CreateGoodstypes < ActiveRecord::Migration
  def change
    create_table :goodstypes do |t|
      t.string :gtno
      t.string :name

      t.timestamps
    end
  end
end
