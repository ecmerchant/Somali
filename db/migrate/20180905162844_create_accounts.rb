class CreateAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :accounts do |t|
      t.string :user
      t.string :seller_id
      t.string :mws_auth_token
      t.string :mws_aws_key
      t.string :mws_secret_key

      t.timestamps
    end
  end
end
