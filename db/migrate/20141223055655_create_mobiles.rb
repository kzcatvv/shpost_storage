class CreateMobiles < ActiveRecord::Migration
  def change
    create_table :mobiles do |t|
      t.string :no
      t.string :mobile_type
      t.string :version
      t.references :user
      t.references :storage
      t.time :last_sign_in_time
      t.boolean :cancel
      t.timestamps
    end
  end
end
