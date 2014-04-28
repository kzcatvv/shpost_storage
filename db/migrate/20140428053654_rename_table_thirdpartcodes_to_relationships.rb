class RenameTableThirdpartcodesToRelationships < ActiveRecord::Migration
  def change
    rename_table :thirdpartcodes, :relationships
  end
end
