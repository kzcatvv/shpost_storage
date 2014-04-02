class AddGoodstypeCommodityToThirdPartCode < ActiveRecord::Migration
  def change
  	add_column :thirdpartcodes, :goodstype_id, :integer 
  	add_column :thirdpartcodes, :commodity_id, :integer
  end
end
