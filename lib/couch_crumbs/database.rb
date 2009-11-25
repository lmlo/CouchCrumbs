module CouchCrumbs
  
  # Direct representation of a CouchDB database (contains documents).
  #
  class Database
    
    include CouchCrumbs::Query
    
    DEFAULT_NAME = :couch_crumbs_database.freeze
    
    attr_accessor :server, :uri, :name, :status
    
    # Get or create a database
    #
    def initialize(opts = {})
      self.server = opts[:server] || CouchCrumbs::default_server
      self.name = (opts[:name] || DEFAULT_NAME).to_s
      self.uri = File.join(server.uri, self.name)

      begin
        self.status = RestClient.get(uri)
      rescue RestClient::ResourceNotFound
        RestClient.put(uri, "{}")
        retry
      end      
    end
    
    # Return an array of all documents
    #
    def documents(opts = {})
      # Query the special built-in _all_docs view
      _query(File.join(uri, "_all_docs"), opts).collect do |doc|
        # Regular documents
        if doc["type"]
          # Eval the class (with basic filtering, i.e. trusting your database)
          eval(doc["type"].gsub(/\W/i, '')).get!(doc["_id"])
          
        elsif doc["_id"] =~ /^\_design\//
          # Design docs
          Design.get!(self, :id => doc["_id"])
        else
          # Ignore any other docs
          warn "skipping unknown document: #{ doc }"
          
          nil
        end
      end
    end
          
    # Return an array of only design documents
    #
    def design_documents
      documents(:startkey => "_design/")
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