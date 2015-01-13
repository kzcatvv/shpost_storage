class AddBarcodeToRelationships < ActiveRecord::Migration
  def change
    add_column :relationships, :barcode, :string
    Relationship.find_each do |x|
      x.save
    end
  end
end
