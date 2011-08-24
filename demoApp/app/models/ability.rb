class Ability  
  include CanCan::Ability  
  
  def initialize(user)  
    user ||= User.new # Guest user created on the fly
    puts "checking if user #{user} can do something"
    if user.role? :admin  
      can :manage, :all  
    else  
      can :read, :all  
      can :create, Comment  
      if user.role?(:author)  
        can :create, Article  
        can :update, Article do |article|  
          article.try(:user) == user  
        end  
      end  
    end  
 end
end 
