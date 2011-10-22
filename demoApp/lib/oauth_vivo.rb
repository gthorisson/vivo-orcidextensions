require 'omniauth/oauth'
require 'restclient'
require 'rdf'
require 'rdf/raptor'
require 'rdf/ntriples'
require 'pp'
include RDF # Bring in several standard vocabularies like FOAF

# Plugin for OmniAuth for handling external authentication & profile exchange
# with a OAuth-enabled VIVO instance

module OmniAuth
  module Strategies
    class Vivo < OmniAuth::Strategies::OAuth
      def initialize(app, consumer_key=nil, consumer_secret=nil, options={}, &block)
        client_options = {
          :access_token_path => '/railsext/oauth/access_token',
          :authorize_path => '/railsext/oauth/authorize',
          :request_token_path => '/railsext/oauth/request_token',
          :scheme => :header,
          :site => 'http://vivo.crossref.org',
        }
        client_options[:authorize_path] = '/railsext/oauth/authorize' unless options[:sign_in] == false
        super(app, :vivo, consumer_key, consumer_secret, client_options, options, &block)
      end

      # Add user profile data to the OAuth parameters already in hand
      def auth_hash

        hash = user_hash(@access_token)
        puts "got final hash with user info:"
        pp hash

        OmniAuth::Utils.deep_merge(
          super, {
            'uid' => hash.delete('id'), # a unique user ID in this authn system
            'user_info' => hash, # additional information about the user
          }
        )
      end

      # Retrieve user profile info from the provider, via the OAuth::Access object
      def user_hash(access_token)

        # First need the account info which includes the VIVO URI pointing to the profile
        begin
          # Make signed request to the OAuth API endpoint
          response = access_token.get('/railsext/oauth/account', { 'Accept'=> 'text/json'})
        rescue
          puts "An error occurred when retrieving user profile: #{$!}"
          # ToDo: proper failure-handling here, need to give useful message back to client app if things don't work out
        end
        puts "response from OAuth call=\n" + response.body
        
        
        # Once we have the URI, we can do a straight-up Linked Data request to grab the RDF
        # ATTN HARDCODED to static N-Triples file for now, until I sort out crazy Raptor RDF-parser bug on OS X
        profile_uri = "/Users/mummi/cvswork/vivo-orcidextensions/demoApp/n80.nt"
        profilegraph = RDF::Graph.load(profile_uri)

        # Let's see the list of triples we've pulled back from VIVO
        puts "Got RDF response, raw triple assertions="
        profilegraph.each_statement do |statement|
          puts 'raw stmt = ' +  statement.inspect
        end
        
        # A simple graph pattern to pull out basic profile info
        query = RDF::Query.new({
          :person => {
            RDF.type  => FOAF.Person,
            RDFS.label => :label,
            FOAF.firstName => :firstName,
            FOAF.lastName => :lastName,
          }
        })
#        puts "printing out solutions to query"
#        query.execute(profilegraph).each do |solution|
#          print "solution: "
#          solution.each_binding do |n,v|
#            puts " #{n}=#{v}"
#          end
#          print "\n"
#        end
        solution = query.execute(profilegraph).first

        user_hash = solution.to_hash
        pp user_hash
        user_hash.stringify_keys! # Change hash keys from symbols to strings
        pp user_hash
        user_hash.each do |key, val|
          puts "checking if val for key #{key} is a URI or a literal: #{val.inspect} "
          user_hash[key] = val.to_s if val.respond_to? :to_s
        end
        pp user_hash
        user_hash['id']  = profile_uri
        user_hash['uri'] = profile_uri
        return user_hash
      end

      # Do later: handle 301 redirects to get to VIVO profile properly
      # http://stackoverflow.com/questions/7210232/ruby-nethttp-following-301-redirects
      #def get_response_with_redirect(uri)
      #  r = Net::HTTP.get_response(uri)
      #  if r.code == "301"
      #    r = Net::HTTP.get_response(URI.parse(r.header['location']))
      #  end
      #  r
      #end
    end
  end
end
