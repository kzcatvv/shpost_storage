class AddRelationshipToStocks < ActiveRecord::Migration
  def change
    add_column :stocks, :relationship_id, :integer
    
    Stock.find_each do |stock|
      stock.update(relationship_id: Relationship.find_by(specification_id: stock.specification, business_id: stock.business, supplier_id: stock.supplier))
    end
  end
end
