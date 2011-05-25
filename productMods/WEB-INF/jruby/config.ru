# -*- mode: ruby -*-



require 'rubygems'
require 'bundler/setup'

# Load modules from app subdirectory 
appdir = Dir.getwd + "/" + File.expand_path(File.dirname(__FILE__)).split("/").pop
puts "appdir = " + appdir
Dir.chdir(appdir)

require appdir + '/lib/helpers'
require appdir + '/lib/orcidextensions'


# Start Sinatra application
set :run, false
set :public, appdir +'/public'
set :views, appdir +'/views'
set :environment, :production
run Sinatra::Application
