require 'omniauth/core'
require 'omniauth/oauth'
require 'oauth_vivo'
require 'oauth_orcid'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, 'eSX0sdHDODy1bdUFX5oAw', 'Wdh2Eo5CtYrIVfeogDVrjjMa6dee18H96FCqdCYc'
  provider :linked_in, 'wuMhoPkGgwUceF_btprE1PVs8odcSTGDxJDeHRwsDKfYPAjROJmTDvBcvs1hBsU3', 'BMujro7Ee-S2oA6vLbisyWvpjg9eROFuayVMu0aq2iUToCvOPR2-m9uxoqQ_i59R'  
  provider :vivo, 'AzwKEFNz3yePTF0XsmyvQPYBRYSvtnzKOF6TkyLL','SnJ8n17xLHwh3UsqhrQlt6NIUTkmKYsvavmoX7c1'
  provider :orcid, 'DqaX7eXx7HkgVAOsRiFo7LL0fTncCW65HXkPU8za','2YrVj3PEq4sKUyj4Y30c4OwMPHO56UCCwjdYcnJk'
end
