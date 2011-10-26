require 'oauth'

class ClientApplication < ActiveRecord::Base

  #attr_accessor :token_callback_url, :name, :support_url, :callback_url, :url
  attr_accessor :token_callback_url
  
  belongs_to :user
  has_many :tokens, :class_name => "OauthToken"
  has_many :access_tokens
  has_many :oauth2_verifiers
  has_many :oauth_tokens
  validates_presence_of :name, :url, :key, :secret
  validates_uniqueness_of :key
  before_validation :generate_keys, :on => :create

  validates_format_of :url, :with => /\Ahttp(s?):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/i
  validates_format_of :support_url, :with => /\Ahttp(s?):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/i, :allow_blank=>true
  validates_format_of :callback_url, :with => /\Ahttp(s?):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/i, :allow_blank=>true

  def self.find_token(token_key)
    token = OauthToken.find_by_token(token_key, :include => :client_application)
    if token && token.authorized?
      token
    else
      nil
    end
  end

  def self.verify_request(request, options = {}, &block)
    begin
      signature = OAuth::Signature.build(request, options, &block)
      return false unless OauthNonce.remember(signature.request.nonce, signature.request.timestamp)
      value = signature.verify
      value
    rescue OAuth::Signature::UnknownSignatureMethod => e
      false
    end
  end

  def oauth_server
    @oauth_server ||= OAuth::Server.new("http://your.site")
  end

  def credentials
    @oauth_client ||= OAuth::Consumer.new(key, secret)
  end

  # If your application requires passing in extra parameters handle it here
  def create_request_token(params={})
    puts "creating request token for client app, w/ custom callback_url including params="
    pp params
    uri = URI.parse(self.callback_url)
    uri.query = params.map { |k,v| [k, CGI.escape(v)] * "=" } * "&"
    puts "created callback_url=" + uri.to_s
    #token = RequestToken.create :client_application => self, :callback_url=>self.token_callback_url
    token = RequestToken.create :client_application => self, :callback_url=>uri.to_s
    pp token    
    token.save
    return token
    #RequestToken.create :client_application => self, :callback_url=>self.token_callback_url
  end


  protected

  def generate_keys
    self.key = OAuth::Helper.generate_key(40)[0,40]
    self.secret = OAuth::Helper.generate_key(40)[0,40]
  end
end
