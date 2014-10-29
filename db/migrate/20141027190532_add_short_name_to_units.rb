class AddShortNameToUnits < ActiveRecord::Migration
  def change
    add_column :units, :short_name, :string
  end
end
