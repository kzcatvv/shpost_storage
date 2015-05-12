class ChangeRequestAndResponseTypeOnMobileLogs < ActiveRecord::Migration
  def change
    remove_column :mobile_logs, :request
    add_column :mobile_logs, :request, :text
    remove_column :mobile_logs, :response
    add_column  :mobile_logs, :response, :text
  end
end
