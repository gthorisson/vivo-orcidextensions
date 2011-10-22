require 'omniauth/core'
require 'omniauth/oauth'
require 'oauth_vivo'
require 'oauth_orcid'
require 'oa-openid'
require 'openid/store/filesystem'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, 'eSX0sdHDODy1bdUFX5oAw', 'Wdh2Eo5CtYrIVfeogDVrjjMa6dee18H96FCqdCYc'
  provider :linked_in, 'wuMhoPkGgwUceF_btprE1PVs8odcSTGDxJDeHRwsDKfYPAjROJmTDvBcvs1hBsU3', 'BMujro7Ee-S2oA6vLbisyWvpjg9eROFuayVMu0aq2iUToCvOPR2-m9uxoqQ_i59R'  
  provider :open_id, OpenID::Store::Filesystem.new('/tmp')
  provider :vivo, 'AzwKEFNz3yePTF0XsmyvQPYBRYSvtnzKOF6TkyLL','SnJ8n17xLHwh3UsqhrQlt6NIUTkmKYsvavmoX7c1'
  provider :orcid, 'e762459e-d428-4e60-9b7d-bc47ceddca92','81af0b49-6506-4c82-bbc6-e170bc15a643'
end
