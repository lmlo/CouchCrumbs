module CouchCrumbs
  
  # Represents "special" design documents
  #
  class Design
    
    attr_accessor :raw, :uri

    # Return a single design doc (from a specific database)
    #
    # ==== Parameters
    # database<String>:: database instance
    # opts => name<String>:: design doc name (i.e. "person")
    # opts => id<String:: id of an existing design doc (i.e. "_design/person")
    #
    def self.get!(database, opts = {})
      raise "opts must contain an :id or :name" unless (opts.has_key?(:id) || opts.has_key?(:name))
      
      # Munge the URI from an :id or :name
      uri = File.join(database.uri, (opts[:id] || "_design/#{ opts[:name] }"))
            
      begin
        # Try for an existing doc
        result = RestClient.get(uri)
        
        design = Design.new(database, :json => result)
      rescue RestClient::ResourceNotFound
        # Or create a new one
        design = Design.new(database, :name => File.basename(uri))
        
        design.save!
      end
      
      design
    end

    # Instantiate a new design document
    #
    # ==== Parameters
    # database<String>:: database instance
    # opts => json<String>:: raw json to init from
    # opts => name<String>:: design doc name (i.e. "person")
    #
    def initialize(database, opts = {})
      if opts.has_key?(:json)
        self.raw = JSON.parse(opts[:json])
      elsif opts.has_key?(:name)        
        # Read the design doc template
        template = File.read(File.join(File.dirname(__FILE__), "templates", "design.json"))

        # Make our substitutions
        template.gsub!(/\#design_id/, "_design/#{ opts[:name] }")
      
        # Init the raw hash
        self.raw = JSON.parse(template)
      else
        raise "#new must have :json or a :name supplied"
      end
      
      # Set out unique URI
      self.uri = File.join(database.uri, id)
    end
    
    # Return design doc id (typically "_design/resource")
    #
    def id
      raw["_id"]
    end
  
    # Return the revision
    #
    def rev
      raw["_rev"]
    end
  
    # Return the design name (id - prefix, i.e. "resource")
    #
    def name
      raw["_id"].split("/").last
    end
    
    # Save the design to the database
    #
    def save!
      result = JSON.parse(RestClient.put(uri, raw.to_json))
    
      # update our stats
      raw["_id"] = result["id"]
      raw["_rev"] = result["rev"] 
    
      result["ok"]
    end
  
    # Remove a design from the database
    #
    def destroy!
      freeze
            
      result = JSON.parse(RestClient.delete(File.join(uri, "?rev=#{ rev }")))
    
      result["ok"]
    end
  
    # Return all views of this design doc
    # opts => supply a name to select a specific view
    #
    def views(opts = {})
      if opts.has_key?(:name)
        View.new(self, opts[:name].to_s, {:name => raw["views"][opts[:name].to_s]}.to_json)
      else
        raw["views"].collect do |key, value|
          View.new(self, key.to_s, {key => value}.to_json)
        end
      end
    end
  
    # Append a view to the view list
    #
    def add_view(view)
      raise ArgumentError.new("view must be of kind View: #{ view }") unless view.kind_of?(View)
      
      raw["views"].merge!(view.raw)
      
      save!
    end
  
  end
  
end
