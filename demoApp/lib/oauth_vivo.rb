require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    class Vivo < OmniAuth::Strategies::OAuth
      def initialize(app, consumer_key=nil, consumer_secret=nil, options={}, &block)
        client_options = {
          :access_token_path => '/railsext/oauth/access_token',
          :authorize_path => '/railsext/oauth/authorize',
          :request_token_path => '/railsext/oauth/request_token',
          :scheme => :header, #:query_string, 
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

        puts "in user_hash(), fetching profile data via OAuth token"

        begin
          #response = access_token.get('/rails/api/users/profile')
          response = access_token.request(:get,
                                          'http://vivo.crossref.org/individual/n  80/n80.rdf',
                                          { 'Accept'=>'application/rdf+xml'})   
          p "response.body="
          pp response.body
        rescue
          puts "An error occurred when retrieving user profile: #{$!}"
        end
        
        # ToDo: RDF-to-hash conversion
 
        hash = MultiJson.decode(response.body)        
        return hash['user']
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
