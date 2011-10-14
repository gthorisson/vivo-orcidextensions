class AddFieldsToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :firstname, :string
    add_column :profiles, :lastname, :string
    add_column :profiles, :middleinitials, :string
  end

  def self.down
    remove_column :profiles, :middleinitials
    remove_column :profiles, :lastname
    remove_column :profiles, :firstname
  end
end
