
# Handle requests having to do with user profile data. At present this
# is for OAuth requests exclusively.

class UsersController < ApplicationController
  
  def show
    
    #Error handling: if there isn't a valid authz token, then abort. at the mo this will
    # bomb if token is not defined, but that's not very elegant..
    #   current_token
    #   TODO return 404 ? 

    # The  token is linked to a specific user, so we retrieve that user record and render as JSON
    user = User.find(current_token.user_id)
    render :json => user

    # FOR VIVO: this controller is *not* necessary. Profile data will be fetched directly from publicly-accessible URI
    
  end

end
