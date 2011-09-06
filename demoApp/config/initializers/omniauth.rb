require 'omniauth/core'
require 'omniauth/oauth'
require 'oauth_vivo'
require 'oauth_orcid'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, 'eSX0sdHDODy1bdUFX5oAw', 'Wdh2Eo5CtYrIVfeogDVrjjMa6dee18H96FCqdCYc'
  provider :linked_in, 'wuMhoPkGgwUceF_btprE1PVs8odcSTGDxJDeHRwsDKfYPAjROJmTDvBcvs1hBsU3', 'BMujro7Ee-S2oA6vLbisyWvpjg9eROFuayVMu0aq2iUToCvOPR2-m9uxoqQ_i59R'  
  provider :vivo, 'AzwKEFNz3yePTF0XsmyvQPYBRYSvtnzKOF6TkyLL','SnJ8n17xLHwh3UsqhrQlt6NIUTkmKYsvavmoX7c1'
  provider :orcid, 'KL6mgdWPAeIdmGvV5U5aOFXYmB2TpsfkkvPljfEi','G7d7WS9kf2Sq47aw6smCzJOE7AwXOz9O2fvpFanp'
end
