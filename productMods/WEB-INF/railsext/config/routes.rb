VivoRailsExt::Application.routes.draw do

  scope "/railsext" do
    get "/oauth/account" => "users#show", :as => :account
    
    root :to => "home#index"
    
    devise_for :users 
    
    resources :oauth_clients

    match "/biblio/fetch",  :to => 'biblio#fetch'
    match "/biblio/search", :to => 'biblio#search'

    match '/oauth/test_request',  :to => 'oauth#test_request',  :as => :test_request
    match '/oauth/token',         :to => 'oauth#token',         :as => :token
    match '/oauth/access_token',  :to => 'oauth#access_token',  :as => :access_token
    match '/oauth/request_token', :to => 'oauth#request_token', :as => :request_token
    match '/oauth/authorize',     :to => 'oauth#authorize',     :as => :authorize
    match '/oauth/revoke',        :to => 'oauth#revoke',        :as => :revoke
    match '/oauth',               :to => 'oauth#index',         :as => :oauth
  end
  
end
