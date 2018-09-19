class RemoveConditionFromProducts < ActiveRecord::Migration[5.0]
  def change
    remove_column :products, :condition, :string
  end
end
