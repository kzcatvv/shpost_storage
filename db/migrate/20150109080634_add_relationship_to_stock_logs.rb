class AddRelationshipToStockLogs < ActiveRecord::Migration
  def change
    add_column :stock_logs, :relationship_id, :inter
    StockLog.find_each do |stock_log|
      stock_log.update(relationship_id: Relationship.find_by(specification_id: stock_log.specification, business_id: stock_log.business, supplier_id: stock_log.supplier))
    end
  end
end
