class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :email
      t.string :username
      t.string :password
      t.integer :verified
      t.string :otp_secret
      t.string :opt_enabled
      t.integer :created_at
      t.integer :updated_at

      t.timestamps
    end
  end
end
