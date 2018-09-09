class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products do |t|
      t.string :user
      t.string :asin
      t.string :condition
      t.integer :new_sale1
      t.integer :new_sale2
      t.integer :new_sale3
      t.integer :new_avg3
      t.integer :used_sale1
      t.integer :used_sale2
      t.integer :used_sale3
      t.integer :used_avg3
      t.boolean :check1
      t.integer :cart_price
      t.integer :cart_income
      t.integer :used_price
      t.integer :used_income
      t.boolean :check2
      t.string :title
      t.string :mpn
      t.string :item_image

      t.timestamps
    end
  end
end
