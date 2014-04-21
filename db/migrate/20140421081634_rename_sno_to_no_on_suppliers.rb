class RenameSnoToNoOnSuppliers < ActiveRecord::Migration
  def change
    rename_column :suppliers, :sno, :no
  end
end
