
# Handle requests having to do with user profile data. At present this
# is for OAuth requests exclusively.

class UsersController < ApplicationController

  oauthenticate :strategies => :token
  #oauthenticate :interactive => true, :strategies => :oauth20_request_token
  #before_filter :oauth_required
  #oauthenticate

  # Display account information
  def show
    
    puts "In users show(), OAuth-protected."
    pp params
    # The  token is linked to a specific user, so we retrieve that user record and render as JSON
    token = current_token
    puts "token="
    pp token
    #user = User.find(token.user_id)
    user = token.user
    pp user
    begin
      render :json => user
    rescue
      puts "Error in returning user object as JSON: #{$!}"
    end
  end

end
