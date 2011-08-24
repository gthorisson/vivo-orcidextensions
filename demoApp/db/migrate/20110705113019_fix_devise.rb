class FixDevise < ActiveRecord::Migration
  def self.up
    create_table(:users) do |t|
      t.database_authenticatable
      t.confirmable
      t.recoverable
      t.rememberable
      t.trackable
      t.string :encrypted_password, :limit => 128      
    end
  end



  def self.down
    drop_table :users
  end


end
