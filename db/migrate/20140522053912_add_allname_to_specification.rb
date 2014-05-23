class AddAllnameToSpecification < ActiveRecord::Migration
  def change
  	add_column :specifications, :all_name, :string
  end
end
