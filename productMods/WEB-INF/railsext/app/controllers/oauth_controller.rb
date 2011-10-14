require 'oauth/controllers/provider_controller'

# Handle OAuth requests. The parent class does nearly all the work, but we do need to
# customize a little bit to make it work for this specific application.
class OauthController < ApplicationController
  include OAuth::Controllers::ProviderController
  
  # Only valid users should be able to authorize & revoke access from apps
  before_filter :authenticate_user_vivo, :only => [:authorize,:revoke]


  # NB this action is inherited from the superclass and for the time behing is a 
  # Rails template.  But perhaps this needs to instead be a native VIVO controller + template
  #def authorize end 
  
  # Determine whether user has granted app access or not, based on parameters from authorize page form
  def user_authorizes_token?
    puts "in user_authorizes_token"
    puts "Rails params from authz form="
    pp params

    puts "params from servlet request="
    servlet_request_params = servlet_request.get_parameter_map()
    pp (servlet_request_params || "")

    #params[:authorize] == '1'
    return true if params[:authorize]

  end

  def authorize
    puts "in modded authz routine, params from authz form="
    pp params

    puts "params from servlet request="
    servlet_request_params = servlet_request.get_parameter_map()
    pp (servlet_request_params || "")

    super
  end
  
end
