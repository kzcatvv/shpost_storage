class AddNoToStorage < ActiveRecord::Migration
  def change
    add_column :storages, :no, :string
  end
end
