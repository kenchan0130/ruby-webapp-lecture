require 'bundler'

groups = [:default, ENV['RACK_ENV']]
Bundler.require(*groups)

require './app'
run MyApp::Application

