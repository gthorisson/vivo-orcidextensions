class CreateManuscripts < ActiveRecord::Migration
  def self.up
    create_table :manuscripts do |t|
      t.text :title
      t.references :user

      t.timestamps
    end
  end

  def self.down
    drop_table :manuscripts
  end
end
