# -*- coding: utf-8 -*-

class UsersController < ApplicationController

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user]) # create user record
    if @user.save
      
      @profile = @user.profile.new # just empty profile to begin with
      pp @profile
      puts 'rendering new_profile template'
      render 'new_profile', :notice => "Signed up!" and return      
    else
      render "new"
    end
  end


  
  # Show username/pwd and profile data combined
  def account

  end

  # Edit username/pwd  and profile data combined
  def edit

    # NB vantar partial fyrir i) account og ii) profile, nota saman i overall edit page

  end


end
