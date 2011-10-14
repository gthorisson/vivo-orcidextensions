class BiblioController < ApplicationController

  require 'restclient'

  # Constants
  SIGG_URL     = 'http://crossref.org/sigg/sigg/FindWorks'
  DOI_RESOLVER = 'http://dx.doi.org/'


  # Wrapper around the CrossRef SIGG query service
  def search  

    @resultlist = [] # for storing results from bibliosearch

    if params[:query]  

      # Look up bibliographic metadata via CrossRef service
    
      puts "Sending query '#{params[:query]}' to SIGG " + SIGG_URL
      response = RestClient.get SIGG_URL, {:accept => :json,
                                           :params => {:version => 1,
                                                       :access  => "gthorisson%40gmail.com",
                                                       :format  => "json",
                                                       :op      => "AND",
                                                       :expression => params[:query]}}
    
      render :text => response.to_str
    end
  end


  # Wrapper around the CrossRef metadata retrieval service
  def fetch
  
    # For reach DOI passed in, fetch full metadata from CrossRef
    doi = params['doi']

    puts "retrieving DOI metadata via #{DOI_RESOLVER}#{doi}"
    begin
      response = RestClient.get DOI_RESOLVER + doi, {:accept =>  "application/rdf+json"}
      render :text => response.to_str
    rescue # try not blow up if the REST call doesn't return successfully
      puts "An error occurred when looking up #{doi}: #{$!}"
      # ToDo: Return proper error code & useful message!
      render :status => 500, :text => "error in looking up DOI #{doi}: #{$!}"
      
    end
  end
  
end
