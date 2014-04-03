class AddNameToArea < ActiveRecord::Migration
  def change
  	add_column :areas, :name, :string, :null => false, :default => ""
  	change_column :areas, :desc, :string, :null => true, :default => nil
  end
end
