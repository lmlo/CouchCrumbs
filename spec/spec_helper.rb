require "rubygems"
require 'spec'

require "ruby-debug"

$:.unshift(File.dirname(__FILE__) + '/../lib')

require "couch_crumbs.rb"

# Connect to the local/remote CouchDB server
CouchCrumbs::connect

# Bring in the fixtures
fixture_path = File.join(File.dirname(__FILE__), "fixtures")

$:.unshift(fixture_path)

Dir["#{ fixture_path }/*.rb"].each do |path|
  require path
end
