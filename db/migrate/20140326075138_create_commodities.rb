class CreateCommodities < ActiveRecord::Migration
  def change
    create_table :commodities do |t|
      t.string :cno
      t.string :name
      t.integer :goodstype_id

      t.timestamps
    end
  end
end
