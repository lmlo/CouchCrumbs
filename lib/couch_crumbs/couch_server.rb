require "rest_client"
require "json"

class CouchServer

  attr_reader :server
  attr_accessor :status
  
  # Return a sensible default host/port string for a CouchDB server
  #
  def self.default_server_uri
    "http://couchdb.local:5984"
  end

  # Return a database name to use if none are specified
  #
  def self.default_database
    "couch_crumbs"
  end

  #===========================================================================

  def initialize(opts = {})
    raise ArgumentError.new("opts must include a :server URI value: #{ opts }") unless opts.include?(:server)
    
    @server = opts[:server]
    
    couchdb_remote_connect
  end
  
  private
  
  def couchdb_remote_connect
    @status = JSON.parse(RestClient.get(@server))
  end
  
end
  