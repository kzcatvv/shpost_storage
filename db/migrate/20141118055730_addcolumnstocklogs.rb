class Addcolumnstocklogs < ActiveRecord::Migration
  def change
    add_column :stock_logs, :shelf_id, :integer
    add_column :stock_logs, :business_id, :integer
    add_column :stock_logs, :supplier_id, :integer
    add_column :stock_logs, :specification_id, :integer
  end
end
