require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    class Orcid < OmniAuth::Strategies::OAuth
      def initialize(app, consumer_key=nil, consumer_secret=nil, options={}, &block)
        client_options = {
          :access_token_path => '/oauth/access_token',
          :authorize_path => '/oauth/authorize',
          :request_token_path => '/oauth/request_token',
          :scheme => :header, #:query_string, 
          :site => 'http://localhost:3001',
        }
        client_options[:authorize_path] = '/oauth/authorize' unless options[:sign_in] == false
        super(app, :orcid, consumer_key, consumer_secret, client_options, options, &block)
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
          response = access_token.get('/profiles') # ToDo: replace with call to 'full' bio resource
          p "response="
          pp response
          p "response.body="
          pp response.body
        rescue
          puts "An error occurred when retrieving user profile: #{$!}"
        end
        
        hash = MultiJson.decode(response.body)        
        return hash['user']
      end

    end
  end
end
