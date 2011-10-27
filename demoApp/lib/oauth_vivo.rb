require 'omniauth/oauth'
require 'multi_json'
require 'faraday_stack'
require 'rdf'
require 'rdf/raptor'
require 'stringio'
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
        puts "got some user account data as JSON:"
        puts account_data
        
        # Now that the profile URI is in hand, we can do a straight-up Linked Data request to grab the RDF
        #profile_uri = "/Users/mummi/cvswork/vivo-orcidextensions/demoApp/n80.nt"
        profile_uri = account_data['user']['uri']

        #profile_response = access_token.get(profile_uri, :headers => {'Accept'=>'text/turtle'}) do |req|
        # ToDo: set up some fancy-smancy logging and other HTTP goodies to the connection
        # object http://mislav.uniqpath.com/2011/07/faraday-advanced-http/
        conn = Faraday.new :url => profile_uri do |builder|
          builder.use Faraday::Response::Logger,     Logger.new('faraday.log')
          builder.use FaradayStack::FollowRedirects, limit: 3
          builder.use Faraday::Response::RaiseError # raise exceptions on 40x, 50x responses
          builder.use Faraday::Adapter::NetHttp
        end
        conn.headers[:accept] = 'text/turtle'
        profile_response = conn.get profile_uri
        # ToDo: need some handling here for 404s, if this  URI does not in fact point to a proper profile at all
        puts 'raw RDF response: ' + profile_response.body

        # OK, so the following is clunky: because the RDF::Graph.load method won't follow URL redirects,
        # we have to pretent the RDF string is a file, and parse it with a Reader object
        profile_rdf = StringIO.new profile_response.body
        repo = RDF::Repository.new
        reader = RDF::Reader.for(:turtle).new(profile_rdf) do |r|
          puts "Set of statements found by Reader to be inserted into repository:"
          r.each_statement do |statement|
            repo.insert statement
          end
        end
        #profilegraph = RDF::Graph.load(profile_uri)

        # Let's see the list of triples we've pulled back from VIVO
        puts "Set of triple assertions in final repository:"
        repo.each_statement do |statement|
          puts '  -> ' +  statement.inspect
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
        solution = query.execute(repo).first
        print "Query solution: "
        solution.each_binding do |n,v|
          puts " #{n}=#{v}"
        end
        print "\n"
        
        # Maybe need one or two more graph patterns to get the publications out. OR
        # keep it simple and only get bio (names, affiliation etc.)

        # Turn the profile info into a hash that we can use
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
    end
  end
end
