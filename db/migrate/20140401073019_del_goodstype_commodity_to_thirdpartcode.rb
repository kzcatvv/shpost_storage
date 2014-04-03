class DelGoodstypeCommodityToThirdpartcode < ActiveRecord::Migration
  def change
  	remove_column :thirdpartcodes, :goodstype_id 
  	remove_column :thirdpartcodes, :commodity_id
  end
end
