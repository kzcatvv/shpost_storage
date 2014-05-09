class Createrelationshipcontactjointable < ActiveRecord::Migration
  def change
  	create_table :relationships_contacts, id: false do |t|
      t.integer :relationship_id
      t.integer :contact_id
    end
  end
end
