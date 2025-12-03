class AddDeviseToUsers < ActiveRecord::Migration[8.0]
  def change
    # Remove password_digest if it exists (from has_secure_password)
    remove_column :users, :password_digest, :string if column_exists?(:users, :password_digest)

    # Add Devise required columns
    add_column :users, :encrypted_password, :string, null: false, default: ""

    # Recoverable
    add_column :users, :reset_password_token, :string
    add_column :users, :reset_password_sent_at, :datetime

    # Rememberable
    add_column :users, :remember_created_at, :datetime

    # Add indexes
    add_index :users, :email, unique: true
    add_index :users, :reset_password_token, unique: true

    # Make email not null
    change_column_null :users, :email, false
  end
end
