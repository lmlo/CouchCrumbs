require "rubygems"
require 'spec'

require "ruby-debug"

$:.unshift(File.dirname(__FILE__) + '/../lib')

require "couch_crumbs.rb"

# Connect to the local/remote CouchDB server
CouchCrumbs::connect
