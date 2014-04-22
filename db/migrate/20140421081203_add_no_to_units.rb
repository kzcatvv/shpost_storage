class AddNoToUnits < ActiveRecord::Migration
  def change
    add_column :units, :no, :string
  end
end
