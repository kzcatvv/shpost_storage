class AddColumnsToUnit < ActiveRecord::Migration
  def change
    add_column :units, :tcbd_khdh, :string

  end
end
