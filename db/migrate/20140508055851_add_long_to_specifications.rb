class AddLongToSpecifications < ActiveRecord::Migration
  def change
    	add_column :specifications, :long, :float
    	add_column :specifications, :wide, :float
    	add_column :specifications, :high, :float
    	add_column :specifications, :weight, :float
    	add_column :specifications, :volume, :float
 

  end
end
