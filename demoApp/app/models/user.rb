
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :lockable, :timeoutable, :confirmable and :activatable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :roles
  has_many :authentications, :dependent => :destroy
  has_many :manuscripts, :dependent => :destroy
  has_one :profile, :dependent => :destroy

  def apply_omniauth(omniauth)  
    authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'])  
  end

  def password_required?  
    (authentications.empty? || !password.blank?) && super  
  end  
  
end

