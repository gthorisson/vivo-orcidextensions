require 'omniauth/oauth'
require 'multi_json'
require 'pp'
include RDF # Bring in several standard vocabularies like FOAF

# Plugin for OmniAuth for handling external authentication & profile exchange
# with a OAuth-enabled VIVO instance

module OmniAuth
  module Strategies
    class Vivo < OmniAuth::Strategies::OAuth2
      def initialize(app, client_id=nil, client_secret=nil, options = {}, &block)
        client_options = {
          :authorize_url => '/railsext/oauth/authorize',
          :token_url => '/railsext/oauth/token',
          :site => 'http://vivo.crossref.org',
          :token_method => :get
        }
        super(app, :vivo, client_id, client_secret, client_options, options, &block)
      end

      # Configure the kind of OAuth connection being made
      def request_phase
        options[:scope] ||= 'read'
        options[:response_type] ||= 'code'
        super
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

        access_token.options[:mode] = :header

        # First need the account info which includes the VIVO URI pointing to the profile
        begin
          # Make signed request to the OAuth API endpoint
          response = access_token.get('/railsext/oauth/account', :headers => {'Accept'=>'application/json'})
        rescue ::OAuth2::Error => e
          raise e.response.inspect
        end
        account_data = MultiJson.decode(response.body)
        
        # Add in some extra fields that we need elsewhere for profile-retrieval, outside of OmniAuth itself
        account_data['user']['id']  = account_data['user']['uri']
        account_data['user']['profile_format']  = 'text/turtle'
        puts "got some user account data as JSON:"
        puts account_data
        return account_data['user']
      end
    end
  end
end
