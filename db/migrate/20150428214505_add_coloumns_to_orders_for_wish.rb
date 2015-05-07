class AddColoumnsToOrdersForWish < ActiveRecord::Migration
  def change
    add_column :orders, :api_key, :string
    add_column :orders, :exps_guid, :string
    add_column :orders, :exps_reg , :string
    add_column :orders, :exps_type, :string
    add_column :orders, :country , :string
    add_column :orders, :local_name, :string
    add_column :orders, :local_country, :string
    add_column :orders, :local_province, :string
    add_column :orders, :local_city, :string
    add_column :orders, :local_addr, :string
    add_column :orders, :send_province, :string
    add_column :orders, :send_city, :string
    add_column :orders, :logistic_id, :string
    add_column :orders, :country_code , :string
  end
end
