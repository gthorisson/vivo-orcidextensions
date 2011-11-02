require 'faraday_stack'
require 'rdf'
require 'rdf/raptor'
require 'stringio'


class ProfilesController < ApplicationController

  # Handles profile management and display, including OAuth access to protected data
  
  set_tab :profile

  # Only allow a logged-in users to create & update their profiles
  before_filter :authenticate_user!, :only => [:new,:show, :create, :update,:edit, :destroy]

  # Only allow access to public + protected profile  data via OAuth
  before_filter :oauth_required, :only => [:show_cidprofile_full]

  
  def new
    puts "Creating new profile for just-created + authn'd user " + current_user.email
    if profile = current_user.profile      
      redirect_to profile_path, :notice => 'You already have a profile!' and return     
    end
    
    profile_data = {}
    
    # User may have elected to pull in profile info from an external source
    if params[:retrieve_external_profiledata]
      @external_authn = Authentication.find(params[:external_authn_id])
      
      profile_data = retrieve_external_profile_data(@external_authn.profile_uri, @external_authn.profile_format)
      flash[:notice] = 'Retrieved external profile data from '+ @external_authn.provider + ", please review"
    end
    
    @profile = Profile.new(profile_data)
  
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
      redirect_to profile_path, :notice => 'Profile was successfully created.'
    else
      render "new"
    end        
  end

  # Show complete profile only to the user who owns it
  def show
    @profile = current_user.profile

    # ToDo: error message if no profile is found for user

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
    @profile = current_user.profile
  end


  def update
    @profile = current_user.profile
    puts 'Got profile to update='
    pp @profile
    puts "params="
    pp params

    respond_to do |format|
      if @profile.update_attributes(params[:profile])
        format.html { redirect_to(profile_path, :notice => 'Profile was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @profile.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @profile = current_user.profile
    puts 'Got profile to destroy='
    pp @profile
    @profile.destroy    
    flash[:notice] = "Successfully destroyed profile."
    redirect_to account_url
  end


  private
  
  # Fix cryptic issue resulting in NoMethodError ("undefined method `current_user='" [..]
  def current_user=(user)
    sign_in(user)
  end
  
  # Retrieve external profile data using the given URI in the given format
  def retrieve_external_profile_data(uri, format)

    # Via tip from object http://mislav.uniqpath.com/2011/07/faraday-advanced-http/
    conn = Faraday.new :url => uri do |builder|
      #builder.use Faraday::Response::Logger,     Logger.new('faraday.log')
      builder.use FaradayStack::FollowRedirects, limit: 3
      builder.use Faraday::Response::RaiseError # raise exceptions on 40x, 50x responses
      builder.use Faraday::Adapter::NetHttp
    end
    conn.headers[:accept] = format
    puts "Retrieving profile data from " + uri + " as " + format
    profile_response = conn.get uri
    puts 'raw profile data: ' + profile_response.body

    # For the moment we just want to handle a couple of main profile formats. No
    # attempt at this time to normalize into some standard representation.
    case format
      when "application/json"  # NB can add multiple conditions here, like text/json or whatever
        parse_profile_data_json profile_response.body
      when "text/turtle"
        parse_profile_data_rdf profile_response.body
      else
        # some useful error message here, or perhaps just return nil
    end
  end

  # Parase profile JSON and return as a hash
  def parse_profile_data_json(profile_string)
    profile_hash_org = MultiJson.decode(profile_string)['profile-list']['researcher-profile']
    profile_hash = {
        :firstname => profile_hash_org['first-name'],
        :lastname  => profile_hash_org['last-name'],
       }
    puts "Final hash with profile data from JSON"
    pp profile_hash
    return profile_hash
  end


  # Parse profile RDF and return as a hash
  def parse_profile_data_rdf(profile_string)
    
    # OK, so the following is clunky: because the RDF::Graph.load method won't follow URL redirects,
    # we have to pretent the RDF string is a file, and then parse it with a Reader object
    profile_rdf = StringIO.new profile_string
    repo = RDF::Repository.new
    reader = RDF::Reader.for(:turtle).new(profile_rdf) do |r|
      puts "Set of statements found by Reader to be inserted into repository:"
      r.each_statement do |statement|
      repo.insert statement
      end
    end
    # Let's see the list of triples we've found in there
    puts "Set of triple assertions in final repository:"
    repo.each_statement do |statement|
      puts '  -> ' +  statement.inspect
    end
        
    # Set up a simple graph pattern to pull out basic profile info from the graph
    query = RDF::Query.new({
      :person => {
        #RDFS.label => :label,
        FOAF.firstName => :firstname,
        FOAF.lastName => :lastname,
      }
    })
    solution = query.execute(repo).first
    print "Query solution: "
    solution.each_binding do |n,v|
      puts " #{n}=#{v}"
    end
    print "\n"
        
        # Maybe need one or two more graph patterns to get the publications out. OR
        # just keep it simple and only get basic bio for now.

    # Turn the profile info into a hash that we can use
    profile_hash = solution.to_hash
    puts "raw solution hash="
    pp profile_hash
    
    # Clean up a few attributes we don't want downstream
    profile_hash.delete(:person)
    #profile_hash.stringify_keys! # Change hash keys from symbols to strings
    profile_hash.each do |key, val|
      puts "checking if val for key #{key} is a URI or a literal: #{val.inspect} "
      profile_hash[key] = val.to_s if val.respond_to? :to_s
    end

    puts "Final hash with profile data from RDF:"
    pp profile_hash
    return profile_hash 
  end
end

