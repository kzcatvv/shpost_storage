class RenameProducNoToSkuOnSpecifications < ActiveRecord::Migration
  def change
    rename_column :specifications, :product_no, :sku
  end
end
