class Addindextocontactsrelationships < ActiveRecord::Migration
  def change
  	add_index :contacts_relationships, [:contact_id, :relationship_id], :unique => true
  end
end
