class ChangeRequestParamsTypeOnMobileLogs < ActiveRecord::Migration
  def change
    remove_column :mobile_logs, :request_params
    add_column :mobile_logs, :request_params, :text
  end
end
