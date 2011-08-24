class ProfilesController < ApplicationController

  # before_filter :authenticate_user!
  set_tab :account


  def new
    @profile = Profile.new
  end

  def create
    
    @profile = current_user.profiles.new(params[:profile])
    if @profile.save
      pp @profile
      redirect_to(@profile, :notice => 'Post was successfully created.') 
    else
      render "new"
    end        
  end

  def show

  end

  def edit

  end

end
