class Modmodeltospecification < ActiveRecord::Migration
  def change
  	remove_column :specifications, :model
  end
end
