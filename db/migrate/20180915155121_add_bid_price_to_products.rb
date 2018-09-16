class AddBidPriceToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :new_bid_price, :integer
    add_column :products, :used_bid_price, :integer
    add_column :products, :new_negotiate_price, :integer
    add_column :products, :used_negotiate_price, :integer
  end
end
