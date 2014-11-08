class ChangeQgPeriodToExpirationDateOnPurchaseDetails < ActiveRecord::Migration
  def change
    rename_column :purchase_details, :qg_period, :expiration_date
    change_column :purchase_details, :expiration_date, :date
  end
end
