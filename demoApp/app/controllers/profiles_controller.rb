class ProfilesController < ApplicationController

  # Handles profile management and display, including OAuth access to protected data
  
  set_tab :profile

  # Only allow a logged-in users to create & update their profiles
  before_filter :authenticate_user!, :only => [:new, :create, :update,:edit]

  # Only allow access to public + protected profile  data via OAuth
  before_filter :oauth_required, :only => [:show_cidprofile_full]

  
  def new
    puts "Creating new profile for just-created + authn'd user " + current_user.email
    @profile = Profile.new
  end

  def create
    @profile = current_user.build_profile(params[:profile])

    # Generate ORCID identifier via built-in random no. generation utility & format
    #   -sample: 1422-4586-3573-0476
    cid = '%016d' % rand( 10000_0000_0000_0000-1 ) # Want 16-digit number
    cid.gsub!(/(\d{4})/,'\1-') # Make readable by clustering into groups of four digits
    cid.chop!
    puts 'generated nice-looking CID=' + cid
    @profile.cid = cid
    if @profile.save
      puts 'created new profile for user ' + current_user.email
      pp @profile
      #redirect_location_for(current_user, )
      # ToDo more sensible redirection behaviour here, after a user has created a profile
      redirect_to account_path, :notice => 'Profile was successfully created.'
    else
      render "new"
    end        
  end

  # Show complete profile only to the user who owns it
  def show
    #@profile = Profile.find(params[:id])
    @profile = current_user.profile

    puts 'Got profile='
    pp @profile

    puts 'got other_names='
    pp @profile.other_names

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml  => @profile }
      format.json  { render :json => @profile }
    end
    
  end

  # Show public profile information, no restrictions
  # 
  def show_cidprofile_publiconly
    @profile = Profile.find_by_cid(params[:cid])
    puts 'found profile by cid=' + params[:cid]

    # Crude: copy the (hardcoded) public attributes from profile object
    # NB this ideally needs a deep copy/clone to also cover info from associated models
    profile_atts = @profile.clone_attributes
    profile_atts_public = {}
    ['cid','firstname','lastname',  'middleinitials'].each do |key|
      profile_atts_public[key] = profile_atts[key]
    end
      
    puts 'Showing public-only profile info:'
    pp profile_atts_public
    pp @profile
    respond_to do |format|
      format.html do
        params[id] = @profile.id
        #forward 'show'
        #redirect_to profile_path(@profile)}
        render "show_public"
      end
      format.xml   { render :xml  => profile_atts_public }
      format.json  { render :json => profile_atts_public }
    end
    
  end

  # Show public + protected profile information, limited to authorized OAuth access
  #
  def show_cidprofile_full
    puts 'got signed request from an OAuth consumer:'
    pp current_token
    pp current_client_application
    
    @profile = Profile.find_by_cid(params[:cid])
    puts 'found profile by cid=' + params[:cid]
    
    puts 'Showing all profile info:'
    pp @profile
    respond_to do |format|
      format.xml   { render :xml  => @profile }
      format.json  { render :json => @profile }
    end   
    
  end

  def edit
    @profile = Profile.find(params[:id])
  end


  def update
    @profile = Profile.find(params[:id])

    respond_to do |format|
      if @profile.update_attributes(params[:profile])
        format.html { redirect_to(@profile, :notice => 'Profile was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @profile.errors, :status => :unprocessable_entity }
      end
    end
  end


  private
  
  # Fix cryptic issue resulting in NoMethodError ("undefined method `current_user='" [..]
  def current_user=(user)
    sign_in(user)
  end
  

end
