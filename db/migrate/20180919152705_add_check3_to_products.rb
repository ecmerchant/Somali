class AddCheck3ToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :check3, :boolean
  end
end
