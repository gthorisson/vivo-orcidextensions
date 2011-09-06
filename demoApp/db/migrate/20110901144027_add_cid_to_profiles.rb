class AddCidToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :cid, :string
  end

  def self.down
    remove_column :profiles, :cid
  end
end
