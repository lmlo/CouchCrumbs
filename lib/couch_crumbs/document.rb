require "validatable"

module CouchCrumbs
  
  class Document
    
    #include Validatable

    attr_accessor :database, :id, :rev, :uri, :json
    attr_writer :new_document
    
    def initialize(opts = {})
      self.database = CouchCrumbs::default_database
      self.id = opts[:id] || database.server.uuids
      self.rev = opts[:rev] || nil
      self.uri = File.join(database.uri, id)
      self.new_document = opts[:new_document] || true
      self.json = opts[:json] || "{}"
    end
    
    # Return a specific document given an id
    #
    def self.get!(id)
      result = JSON.parse(RestClient.get(File.join(CouchCrumbs::default_database.uri, id)))
      
      document = Document.new(
        :new_document => false, 
        :id => result["_id"],
        :rev => result["_rev"],
        :json => result
      )
      
      document
    end
    
    # Create and save a new document
    # @todo - add before_create and after_create callbacks
    def self.create(opts = {})
      document = new(opts)
      
      yield document if block_given?
      
      document.save
      
      document
    end
    
    #===========================================================================
    
    def self.property(name, opts = {})
      @@properties ||= []
    end
    
    def self.view_by(name, opts = {})
      
    end
    
    def self.has_many(models, opts = {})
      
    end
    
    def self.belongs_to(model, opts = {})
      
    end
    
    def self.timestamps!
      
    end
    
    def self.save_callback(point, opts = {})
      
    end
    
    def self.validates_with_method(method_name)
      
    end
    
    #===========================================================================
    
    # Return all documents of this type
    #
    def self.all
      
    end
    
    # Save a document to a database
    # @todo - add before_save and after_save callbacks
    def save
      result = JSON.parse(RestClient.put(uri, "{}"))
      
      self.id = result["id"]
      self.rev = result["rev"]
      
      result["ok"]
    end
    
    # Return true prior to document being saved
    #
    def new_document?
      @new_document
    end
    
  end
  
end


