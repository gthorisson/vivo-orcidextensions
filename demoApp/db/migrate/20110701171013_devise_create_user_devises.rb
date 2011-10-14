class DeviseCreateUserDevises < ActiveRecord::Migration
  def self.up
    create_table(:user_devises) do |t|
      t.database_authenticatable :null => false
      t.recoverable
      t.rememberable
      t.trackable

      t.encryptable
      # t.confirmable
      # t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :both
      t.token_authenticatable


      t.timestamps
    end

    add_index :user_devises, :email,                :unique => true
    add_index :user_devises, :reset_password_token, :unique => true
    # add_index :user_devises, :confirmation_token,   :unique => true
    # add_index :user_devises, :unlock_token,         :unique => true
    # add_index :user_devises, :authentication_token, :unique => true
  end

  def self.down
    drop_table :user_devises
  end
end
