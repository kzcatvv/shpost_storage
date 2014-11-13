class AddExpirationDateToStocks < ActiveRecord::Migration
  def change
    add_column :stocks, :expiration_date, :date
  end
end
