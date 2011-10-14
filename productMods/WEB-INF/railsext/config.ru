# This file is used by Rack-based servers to start the application.

puts "Loading Rails app"
require ::File.expand_path('../config/environment',  __FILE__)
run VivoRailsExt::Application
