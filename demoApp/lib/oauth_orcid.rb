require 'omniauth/oauth'
require 'multi_json'

# Plugin for OmniAuth for handling external authentication via the mocked-up ORCID API

module OmniAuth
  module Strategies
    class Orcid < OmniAuth::Strategies::OAuth
      def initialize(app, consumer_key=nil, consumer_secret=nil, options={}, &block)
        client_options = {
          :access_token_path => '/oauth/access_token',
          :authorize_path => '/oauth/authorize',
          :request_token_path => '/oauth/request_token',
          :scheme => :header, 
          :site => 'http://localhost:3001',
        }
        client_options[:authorize_path] = '/oauth/authorize' unless options[:sign_in] == false
        super(app, :orcid, consumer_key, consumer_secret, client_options, options, &block)
      end

      # Add user profile data to the OAuth parameters already in hand, and return this as a standard
      # hash which OmniAuth knows what to do with (see OmniAuth docs for details).
      def auth_hash

        hash = user_hash(@access_token)
        puts "got final hash with user info:"
        pp hash

        puts 'Preparing hash as per OmniAuth convention and returning to caller'
        OmniAuth::Utils.deep_merge(
          super, {
            'uid' => hash['cid'], # The unique contributor identifier
            'user_info' => hash,  # ORCID profile data, including protected fields
          }
        )
      end

      # Retrieve profile data via the OAuth::Access object, and return as hash
      def user_hash(access_token)

        puts "in user_hash(), fetching profile data via OAuth token"
        puts "got access_token.params="
        pp access_token.params

        begin
          # Make signed request to retrieve the profile data, including protected fields. Note
          # ToDo: currently hardcoded for testing purposes - need to alter this to '/profile'
          # ToDo: add version to URL path
          response = access_token.get('/profile', { 'Accept'=>'text/xml'})
        rescue
          puts "An error occurred when retrieving user profile: #{$!}"

          # ToDo: proper failure-handling here, need to give useful message back to client app if things don't work out
        end
        
        puts 'ended up with this as profile data: ' + response.body

        hash = MultiJson.decode(response.body)
        return hash['profile']
      end

    end
  end
end
