class AddProfitRateToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :profit_rate, :integer
    add_column :accounts, :shipping, :integer
    add_column :accounts, :sub_keyword, :string
  end
end
