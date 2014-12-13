class AddColumnsToInterfaceInfos < ActiveRecord::Migration
  def change
    add_column :interface_infos, :business_id, :string
    add_column :interface_infos, :unit_id, :string
    add_column :interface_infos, :storage_id, :string
    add_column :interface_infos, :request_ip, :string
    add_column :interface_infos, :response_ip, :string
  end
end
