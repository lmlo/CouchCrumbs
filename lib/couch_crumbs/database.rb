module CouchCrumbs
  
  # Direct representation of a CouchDB database (contains documents).
  #
  class Database
    
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
    
    # Return an array of all documents (very heavy)
    #
    # === Parameters (see: http://wiki.apache.org/couchdb/HTTP_view_API)
    # key=keyvalue
    # startkey=keyvalue
    # startkey_docid=docid
    # endkey=keyvalue
    # endkey_docid=docid
    # limit=max rows to return This used to be called "count" previous to Trunk SVN r731159
    # stale=ok
    # descending=true
    # skip=number of rows to skip (very slow)
    # group=true Version 0.8.0 and forward
    # group_level=int
    # reduce=false Trunk only (0.9)
    # include_docs=true Trunk only (0.9)
    #
    def documents(opts = {})
      # Build our view query string
      query_params = "?"
      
      if opts.has_key?(:key)
        query_params << %(key="#{ opts.delete(:key) }")
      elsif opts.has_key?(:startkey)
        query_params << %(startkey="#{ opts.delete(:startkey) }")
        if opts.has_key?(:startkey_docid)
          query_params << %(&startkey_docid="#{ opts.delete(:startkey_docid) }")
        end
        if opts.has_key?(:endkey)
          query_params << %(&endkey="#{ opts.delete(:endkey) }")
          if opts.has_key?(:endkey_docid)
            query_params << %(&endkey_docid="#{ opts.delete(:endkey_docid) }")
          end
        end
      end
      
      # Escape the quoted JSON query keys
      query_params = URI::escape(query_params)
      
      # Default options
      (@@default_options ||= {
        :limit            => 25,    # limit => 0 will return metadata only
        :stale            => false, 
        :descending       => false,
        :skip             => nil,   # The skip option should only be used with small values 
        :group            => nil,
        :group_level      => nil,
        :include_docs     => true
      }).merge(opts).each do |key, value|
        query_params << %(&#{ key }=#{ value }) if value
      end
      
      query_string = File.join(uri, "_all_docs#{ query_params }")
            
      # Query the server and return an array of documents (will include design docs)
      JSON.parse(RestClient.get(query_string))["rows"].collect do |row|
        # Regular documents
        if row["doc"]["type"]
          # Eval the class (with basic filtering, i.e. trusting your database)
          eval(row["doc"]["type"].gsub(/\W/i, '')).get!(row["id"])
        elsif row["id"] =~ /^\_design\//
          # Design docs          
          Design.get!(row["id"], self)
        else
          # Ignore any other docs
          warn "skipping unknown document with id: #{ row["id"] }"
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