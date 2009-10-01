require "validatable"

module CouchCrumbs
  
  class Document
    
    #include Validatable
    
    attr_accessor :json
    
    def initialize(database, opts = {})
      
    end
    
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
    
    # Return all documents of this type
    #
    def self.all
      
    end

  end
  
end
