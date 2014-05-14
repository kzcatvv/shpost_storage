class Droprelationshipcontacttable < ActiveRecord::Migration
  def change
  	drop_table :relationships_contacts
  end
end
