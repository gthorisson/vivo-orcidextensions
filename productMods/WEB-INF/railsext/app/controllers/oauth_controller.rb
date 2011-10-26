require 'oauth/controllers/provider_controller'

# Handle OAuth requests. The parent class does nearly all the work, but we do need to
# customize a little bit to make it work for this specific application.
class OauthController < ApplicationController
  include OAuth::Controllers::ProviderController
  
  # Only valid users should be able to authorize & revoke access from apps
  before_filter :authenticate_user_vivo, :only => [:authorize,:revoke]
  oauthenticate :strategies => :oauth20_request_token, :interactive => false, :only => [:access_token]


  # NB this action is inherited from the superclass and for the time behing is a 
  # Rails template.  But perhaps this needs to instead be a native VIVO controller + template
  #def authorize end 
  
  # Determine whether user has granted app access or not, based on parameters from authorize page form
  def user_authorizes_token?
    return true if params[:authorize]

  end
  


  def authorize
    puts "in modded authorize(), params="
    params[:user_email] = current_user.email
    params[:user_uri] = current_user.uri
    pp params
    super
  end
  
  def authorize__FF
    puts "in modded authz routine, params from authz form="
    pp params


    if params[:oauth_token]
      @token = ::RequestToken.find_by_token! params[:oauth_token]

      url = URI.parse(@token.callback_url)
      puts "\@token.callback_url=" 
      pp url
      url.query = params.map { |k,v| [k, CGI.escape(v)] * "=" } * "&"
      puts "made new callback_url=" + url.to_s
      @token.callback_url = CGI.escape(url.to_s)
      puts "\@token in authorize()="
      pp @token
      oauth1_authorize
    elsif ["code","token"].include?(params[:response_type]) # pick flow
      send "oauth2_authorize_#{params[:response_type]}"
    else
      render :status=>404, :text=>"No token provided"
    end
  end
  

  
  
end
