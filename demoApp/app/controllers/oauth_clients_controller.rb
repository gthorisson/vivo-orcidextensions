
# Let users manage OAuth client (aka consumer) apps that are authorized to access their profiles
class OauthClientsController < ApplicationController

  # Only valid users can manage client apps
  before_filter :authenticate_user!
  

  before_filter :get_client_application, :only => [:show, :edit, :update, :destroy]

  # List authorized apps
  def index
    @client_applications = current_user.client_applications
    @tokens = current_user.tokens.find :all, :conditions => 'oauth_tokens.invalidated_at is null and oauth_tokens.authorized_at is not null'
  end

  # Create a new app to authorize
  def new
    @client_application = ClientApplication.new
  end

  # Authorize a new app
  def create
    @client_application = current_user.client_applications.build(params[:client_application])
    if @client_application.save
      flash[:notice] = "Registered the information successfully"
      redirect_to :action => "show", :id => @client_application.id
    else
      render :action => "new"
    end
  end

  # Page showing authorized app details
  def show
  end

  # Page showing for for editing authorized app details
  def edit
  end

  # Handle data from authorized app details edit form
  def update
    if @client_application.update_attributes(params[:client_application])
      flash[:notice] = "Updated the client information successfully"
      redirect_to :action => "show", :id => @client_application.id
    else
      render :action => "edit"
    end
  end
  
  # Delete an authorized app
  def destroy
    @client_application.destroy
    flash[:notice] = "Destroyed the client application registration"
    redirect_to :action => "index"
  end

  private
  def get_client_application
    unless @client_application = current_user.client_applications.find(params[:id])
      flash.now[:error] = "Wrong application id"
      raise ActiveRecord::RecordNotFound
    end
  end
end
