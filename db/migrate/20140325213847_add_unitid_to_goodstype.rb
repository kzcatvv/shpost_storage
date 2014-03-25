class AddUnitidToGoodstype < ActiveRecord::Migration
  def change
  	add_column :goodstypes, :unit_id, :integer
  end
end
