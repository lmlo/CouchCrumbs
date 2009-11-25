module CouchCrumbs
  
  # Mixin to query databases and views 
  module Query
    
    # Query an URI with opts and return an array of ruby hashes 
    # representing JSON docs.
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
    def _query(uri, opts = {})
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
      
      query_string = "#{ uri }#{ query_params }"
      
      # Query the server and return an array of documents (will include design docs)
      JSON.parse(RestClient.get(query_string))["rows"].collect do |row|
        row["doc"]
      end
    end
    
  end
  
end