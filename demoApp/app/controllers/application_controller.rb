class ApplicationController < ActionController::Base

  helper :all # include all helpers, all the time

  protect_from_forgery


  rescue_from CanCan::AccessDenied do |exception|  
    flash[:error] = "Access denied!"  
    redir
  end
end
