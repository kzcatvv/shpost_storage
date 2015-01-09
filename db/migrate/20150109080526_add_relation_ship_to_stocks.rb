class AddRelationShipToStocks < ActiveRecord::Migration
  def change
    add_column :stocks, :relationship_id, :inter
  end
end
