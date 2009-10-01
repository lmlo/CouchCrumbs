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
    @@server = Server.new(:uri => opts[:server_uri])
    @@database = Database.new(@@server, :name => opts[:default_database])
    
    {:success => true, :server => @@server, :database => @@database}
  end
  
  def self.default_server
    @@server or raise "servers are only available after calling CouchCrumbs::connect"
  end
  
  def self.default_database
    @@database or raise "databases are only available after calling CouchCrumbs::connect"
  end
  
end