class AddFieldsToAuthentications < ActiveRecord::Migration
  def change
    add_column :authentications, :profile_uri, :text
    add_column :authentications, :profile_format, :text
  end
end
