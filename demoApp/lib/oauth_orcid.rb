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

        puts 'Preparing hash as per OmniAuth convention and returning to caller'
        OmniAuth::Utils.deep_merge(
          super, {
            'uid' => hash['cid'], # a unique user ID in this authn system
            'user_info' => hash, # additional information about the user
          }
        )
      end

      # Retrieve user profile info from the provider, via the OAuth::Access object
      def user_hash(access_token)

        puts "in user_hash(), fetching profile data via OAuth token"
        puts "got access_token.params="
        pp access_token.params

        begin
          # Make signed request to retrieve the profile data, including protected fields
          response = access_token.get('/cid/0723-1814-6587-5983/full', { 'Accept'=>'application/json'})
        rescue
          puts "An error occurred when retrieving user profile: #{$!}"
        end
        
        puts 'ended up with this as profile data: ' + response.body
        
        hash = MultiJson.decode(response.body)
        #return hash['user']
        return hash['profile']
      end

    end
  end
end
