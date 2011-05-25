# -*- mode: ruby -*-



require 'rubygems'
require 'bundler/setup'

# Load modules from app subdirectory 
puts "__FILE__ = " + __FILE__
puts "File.dirname(__FILE__) = " + File.dirname(__FILE__)

appdir = Dir.getwd + "/" + File.expand_path(File.dirname(__FILE__)).split("/").pop
puts "appdir = " + appdir

puts "\n pwd=#{Dir.getwd}\n"
Dir.chdir(appdir)
puts "\n pwd=#{Dir.getwd}\n"

require appdir + '/lib/helpers'
require appdir + '/lib/orcidextensions'

puts "GOOD TO GO!"

set :run, false
set :public, appdir +'/public'
set :views, appdir +'/views'
set :environment, :production
run Sinatra::Application
