class Profile < ActiveRecord::Base
  belongs_to :user
  has_many :other_names, :dependent => :destroy

end
