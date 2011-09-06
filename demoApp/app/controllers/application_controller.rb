class ApplicationController < ActionController::Base

  
  helper :all # include all helpers, all the time

  # Need some aliases to let the OAuth plugin work with Devise
  alias :logged_in? :user_signed_in?
  alias :login_required :authenticate_user!
  
  protect_from_forgery

end
