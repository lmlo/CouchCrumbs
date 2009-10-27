class Design
  
  attr_accessor :raw, :uri

  # Return a single design doc (optionally from a specific database)
  #
  def self.get!(id, database = CouchCrumbs::default_database)
    Design.new(database, :id => id)
  end
  
  # Return or create a new design doc with an :id or :name parameter
  #
  def initialize(database, opts = {})
    self.raw = {}
    
    # Init from an ID or a name
    if opts[:id]
      raw["_id"] = opts[:id]
    elsif opts[:name]
      raw["_id"] = "_design/#{ opts[:name] }"
    else
      raise "design docs require an :id or :name"
    end
        
    self.uri = File.join(database.uri, id)
    
    begin
      result = RestClient.get(uri)
      
      # Our design doc
      self.raw = JSON.parse(result)
      
    rescue RestClient::ResourceNotFound
      # Read the design doc template
      template = File.read(File.join(File.dirname(__FILE__), "templates", "design.js"))
      
      # Make our subs
      template.gsub!(/\#design_id/, id)

      # Put the result
      result = JSON.parse(RestClient.put(uri, template))
      
      # Re-read the doc
      retry if result["ok"].eql?(true)
    end
  end

  # Return design doc id (typically a UUID)
  #
  def id
    raw["_id"]
  end
  
  # Return the revision
  #
  def rev
    raw["_rev"]
  end
  
  # Return the design name (id - prefix)
  #
  def name
    raw["_id"].split("/").last
  end
  
  # Save the design to the database
  #
  def save!
    result = RestClient.put(uri, raw.to_json)
    
    # update our stats
    raw["_id"] = result["id"]
    raw["_rev"] = result["rev"] 
    
    result["ok"]
  end
  
  # Remove a design from the database
  #
  def destroy!
    freeze
    
    # Design documents should not be deleted?
    #result = JSON.parse(RestClient.delete(File.join(uri, "?rev=#{ rev }")))
    
    #result["ok"]

    true
  end
  
  # Return all views of this design doc
  #
  def views
    raw["views"].collect do |key, value|      
      View.new(({key => value}).to_json)
    end
  end
  
  # Append a view to the view list
  #
  def append_view(view)
    raw["views"].merge!(view.raw)
  end
  
end