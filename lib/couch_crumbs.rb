$:.unshift(File.dirname(__FILE__))

require "core_ext/array.rb"

require "couch_crumbs/server.rb"
require "couch_crumbs/database.rb"
require "couch_crumbs/document.rb"

module CouchCrumbs

  # Connect to a specific couch server/database
  #
  # ==== Parameters
  # server_uri<String>:: host/port in URI form
  # default_database<String>:: default database name
  #
  def self.connect(opts = {})    
    @@default_server = Server.new(:uri => opts[:server_uri])
    @@default_database = Database.new(@@default_server, :name => opts[:default_database])
    
    # return true if both server and database were instantiated 
    (@@default_server && @@default_database)
  end
  
  # Return a default server for use
  #
  def self.default_server
    @@default_server or raise "servers are only available after calling CouchCrumbs::connect"
  end
  
  # Return a default database that models will use
  #
  def self.default_database
    @@default_database or raise "databases are only available after calling CouchCrumbs::connect"
  end
  
end