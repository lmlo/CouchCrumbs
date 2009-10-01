require "rest_client"
require "json"

module CouchCrumbs
  
  class Server

    DEFAULT_URI = "http://couchdb.local:5984".freeze
    
    attr_writer :uri
    attr_accessor :status
  
    # Return a sensible default host/port string for a CouchDB server
    #
    def uri
      @uri ||= DEFAULT_URI
    end
    
    # Create a new instance of Server
    #
    def initialize(opts = {})
      self.uri = opts[:uri] if opts.has_key?(:uri)
      
      self.status = JSON.parse(RestClient.get(self.uri))
    end
    
    # Return an array of databases
    #
    def databases
      # @todo - add a :refresh argument with a 10 second cache of the DBs
      JSON.parse(RestClient.get(File.join(self.uri, "_all_dbs"))).collect do |database_name|
        Database.new(self, :name => database_name)
      end
    end
    
  end
  
end
