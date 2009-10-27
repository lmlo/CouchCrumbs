require "rest_client"
require "json"

module CouchCrumbs
  
  # Represents an instance of a live running CouchDB server
  class Server

    DEFAULT_URI = "http://couchdb.local:5984".freeze
    
    attr_accessor :uri, :status

    # Create a new instance of Server
    #
    def initialize(opts = {})
      self.uri = opts[:uri] || DEFAULT_URI

      self.status = JSON.parse(RestClient.get(self.uri))
    end
    
    # Return an array of databases
    # @todo - add a :refresh argument with a 10 second cache of the DBs
    #
    def databases
      JSON.parse(RestClient.get(File.join(self.uri, "_all_dbs"))).collect do |database_name|
        Database.new(:name => database_name)
      end
    end
    
    # Return a new random UUID for use in documents
    #
    def uuids(count = 1)
      uuids = JSON.parse(RestClient.get(File.join(self.uri, "_uuids?count=#{ count }")))["uuids"]
      
      if count > 1
        uuids
      else
        uuids.first
      end
    end
    
  end
  
end
