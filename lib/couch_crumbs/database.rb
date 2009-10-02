module CouchCrumbs
  
  class Database
    
    DEFAULT_NAME = "couch_crumbs_database".freeze
    
    attr_accessor :server, :database_uri, :name

    # Get or create a database
    #
    def initialize(server, opts = {})
      self.server = server
      self.name = opts[:name] || DEFAULT_NAME
      self.database_uri = File.join(server.uri, self.name)

      begin
        RestClient.get(database_uri)
      rescue RestClient::ResourceNotFound
        RestClient.put(database_uri, {})
      end
    end

    # Delete this database from the server
    #
    def destroy
      JSON.parse(RestClient.delete(database_uri))["ok"]
    end

  end
  
end