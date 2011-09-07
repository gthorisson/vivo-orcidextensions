require 'oauth/controllers/provider_controller'

# Handle OAuth requests. The parent class does nearly all the work, but we do need to
# customize a little bit to make it work for this specific application.
class OauthController < ApplicationController
  include OAuth::Controllers::ProviderController


  # Only valid users should be able to authorize & revoke access from apps
  before_filter :authenticate_user!, :only => [:authorize,:revoke]
  
  # Determine whether user has granted app access or not, based on parameters from authorize page form
  def user_authorizes_token?
    puts "params from authz form="
    pp params
    #params[:authorize] == '1'
    return true if params[:authorize]
  end


  def authorize
    puts "in modded authz routine, params from authz form="
    pp params
    
    super
  end

  
  
end
