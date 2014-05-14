class Createrelationshipcontacttable < ActiveRecord::Migration
  def change
  	create_table :contacts_relationships, id: false do |t|
      t.column "contact_id", :integer, :null => false  
      t.column "relationship_id",  :integer, :null => false
    end
  end
end
