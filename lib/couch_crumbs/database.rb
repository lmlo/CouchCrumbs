module CouchCrumbs
  
  class Database
    
    DEFAULT_NAME = :couch_crumbs_database.freeze
    
    attr_accessor :server, :uri, :name, :status

    # Get or create a database
    #
    def initialize(opts = {})
      self.server = CouchCrumbs::default_server
      self.name = (opts[:name] || DEFAULT_NAME).to_s
      self.uri = File.join(server.uri, self.name)

      begin
        self.status = RestClient.get(uri)
      rescue RestClient::ResourceNotFound
        RestClient.put(uri, "{}")
        retry
      end      
    end
    
    # Return an array of all documents (very heavy)
    #
    def documents(descending = false)
      JSON.parse(RestClient.get(File.join(uri, "_all_docs?descending=#{ descending }")))["rows"].collect do |row|        
        Document.get!(row["id"])
      end
    end
    
    # Delete database from the server
    #
    def destroy!
      freeze
      
      result = JSON.parse(RestClient.delete(uri))["ok"]
            
      result
    end

  end
  
end