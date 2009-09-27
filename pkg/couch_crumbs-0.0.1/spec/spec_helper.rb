begin
  require "rubygems"
  require 'spec'
rescue LoadError
  require 'rubygems' unless ENV['NO_RUBYGEMS']
  gem 'rspec'
  require 'spec'
end

require "ruby-debug"

$:.unshift(File.dirname(__FILE__) + '/../lib')

require "couch_crumbs.rb"





