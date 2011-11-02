require 'omniauth/oauth'
require 'multi_json'

# Plugin for OmniAuth for handling external authentication & profile exchange
# with the mocked-up ORCID API

module OmniAuth
  module Strategies
    class Orcid < OmniAuth::Strategies::OAuth2
      def initialize(app, client_id=nil, client_secret=nil, options = {}, &block)
        client_options = {
          :authorize_url => '/oauth/user/authorize',
          :token_url => '/oauth/authorize',
          :site => 'http://localhost:8080',
        }
        super(app, :orcid, client_id, client_secret, client_options, options, &block)
      end

      # Add user profile data to the OAuth parameters already in hand, and return this as a standard
      # hash which OmniAuth knows what to do with (see OmniAuth docs for details).
      def auth_hash

        hash = user_data(@access_token)
        puts "got final hash with user info:"
        pp hash

        # Preparing hash as per OmniAuth convention and returning to caller
        OmniAuth::Utils.deep_merge(
          super, {
            'uid' => hash['orcid'], # The unique contributor identifier
            'user_info' => hash,  # ORCID profile data, including protected fields
          }
        )
      end
  
      # Configure the kind of OAuth connection being made
      def request_phase
        options[:scope] ||= 'read'
        options[:response_type] ||= 'code'
        # think I can pass in a redirect URL like this
        #options[:redirect_url] ||= [account page]

        super
      end
      

      # Retrieve profile data via the OAuth::Access object, and return as hash
      def user_data(access_token)        

        access_token.options[:mode] = :header
        
        # Make signed request to retrieve profile data as JSON
        # ATTN the contributor ID string is hardcoded here for now
        begin
          response = access_token.get('/9999-2411-9999-4111', :headers => {'Accept'=>'application/json'})
        rescue ::OAuth2::Error => e
          raise e.response.inspect
        end
        userhash = MultiJson.decode(response.body)
        userhash['profile-list']['researcher-profile']['uri']  = 'http://localhost:8080/9999-2411-9999-4111'
        userhash['profile-list']['researcher-profile']['profile_format']  = 'application/json'

        puts "userhash="
        pp userhash
        return userhash["profile-list"]["researcher-profile"]
      end
    end
  end
end
