class ChangeColumnForInterfaceInfo < ActiveRecord::Migration
  def change
  	remove_column :interface_infos, :operate_time
  	remove_column :interface_infos, :url_content
  	remove_column :interface_infos, :type

  	add_column :interface_infos, :first_time, :string
  	add_column :interface_infos, :last_time, :string
  	add_column :interface_infos, :url_request, :text
  	add_column :interface_infos, :url_response, :text
  	add_column :interface_infos, :operate_type, :string
  	add_column :interface_infos, :operate_user, :string
  	add_column :interface_infos, :operate_times, :integer
  	add_column :interface_infos, :params, :string, :limit => 1000

  end
end
