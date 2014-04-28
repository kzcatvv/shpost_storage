class AddSpecDescToRelationships < ActiveRecord::Migration
  def change
    add_column :relationships, :spec_desc,  :string
  end
end
