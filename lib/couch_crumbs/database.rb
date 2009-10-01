module CouchCrumbs
  
  class Database
    
    DEFAULT_NAME = "couch_crumbs_database".freeze
    
    attr_accessor :server, :database_uri
    attr_writer :name
    
    # Return the database name
    #
    def name
      @name ||= DEFAULT_NAME
    end
    
    # Get or create a database
    #
    def initialize(server, opts = {})
      self.server = server
      self.name = opts[:name] if opts.has_key?(:name)
      self.database_uri = File.join("#{ server.uri }", self.name)
      
      status = nil
      
      begin
        status = RestClient.get(database_uri)
      rescue RestClient::ResourceNotFound
        status = RestClient.put(database_uri, {})
      rescue Exception => e
        warn e
      end
    end

    # Delete this database from the server
    #
    def destroy
      JSON.parse(RestClient.delete(database_uri))["ok"]
    end

  end
  
end