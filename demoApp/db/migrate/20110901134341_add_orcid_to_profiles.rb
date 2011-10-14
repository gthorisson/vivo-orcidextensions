class AddOrcidToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :orcid, :string
  end

  def self.down
    remove_column :profiles, :orcid
  end
end
