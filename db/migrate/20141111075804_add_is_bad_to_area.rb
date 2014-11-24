class AddIsBadToArea < ActiveRecord::Migration
  def change
  	add_column :areas, :is_bad, :string,:default => "no"
  end
end
