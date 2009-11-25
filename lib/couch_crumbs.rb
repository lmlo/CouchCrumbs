$:.unshift(File.dirname(__FILE__))

require "facets/string/modulize"

require "core_ext/array.rb"

require "couch_crumbs/server.rb"
require "couch_crumbs/query.rb"
require "couch_crumbs/database.rb"
require "couch_crumbs/document.rb"
require "couch_crumbs/design.rb"
require "couch_crumbs/view.rb"

module CouchCrumbs
  
  # Defaults
  @@default_server = @@default_database = nil
  
  # Connect to a specific couch server/database
  #
  # ==== Parameters
  # server_uri<String>:: host/port in URI form
  # default_database<String>:: default database name
  #
  def self.connect(opts = {})    
    @@default_server = Server.new(:uri => opts[:server_uri])
    @@default_database = Database.new(:name => opts[:default_database])
    
    # return true if both server and database were instantiated 
    (@@default_server && @@default_database) ? true : (raise "unable to connect CouchCrumbs to a CouchDB instance")
  end
  
  # Return a default server for use
  #
  def self.default_server
    @@default_server or (raise "default server is only available after calling CouchCrumbs::connect")
  end
  
  # Return a default database that models will use
  #
  def self.default_database
    @@default_database or (raise "default database is only available after calling CouchCrumbs::connect")
  end
  
end