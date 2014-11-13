class AddColumnsToStorage < ActiveRecord::Migration
  def change
    add_column :storages, :address, :string
    add_column :storages, :phone, :string
    add_column :storages, :postcode, :string
    add_column :storages, :tcbd_product_no, :string
  end
end
