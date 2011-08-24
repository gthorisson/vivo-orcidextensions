
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :lockable, :timeoutable, :confirmable and :activatable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :roles
  has_many :authentications, :dependent => :destroy
  has_many :manuscripts, :dependent => :destroy
  has_many :profiles, :dependent => :destroy

  named_scope :with_role, lambda { |role| {:conditions => "roles_mask & #{2**ROLES.index(role.to_s)} > 0 "} }  
  ROLES = %w[admin moderator author editor]  
  
  def roles=(roles)  
    self.roles_mask = (roles & ROLES).map { |r| 2**ROLES.index(r) }.sum  
  end  
  
  def roles  
    ROLES.reject { |r| ((roles_mask || 0) & 2**ROLES.index(r)).zero? }  
  end  
  
  def role?(role)  
    roles.include? role.to_s  
  end  

  def role_symbols  
    roles.map(&:to_sym)  
  end 

  def apply_omniauth(omniauth)  
    authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'])  
  end

  def password_required?  
    (authentications.empty? || !password.blank?) && super  
  end  
  
end

