class AddUsedProfitRateToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :used_profit_rate, :integer
  end
end
