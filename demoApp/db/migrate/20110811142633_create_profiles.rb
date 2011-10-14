class CreateProfiles < ActiveRecord::Migration
  def self.up
    create_table :profiles do |t|
      t.references :user
      t.text :name
      t.text :affiliation
      t.text :role

      t.timestamps
    end
  end

  def self.down
    drop_table :profiles
  end
end
