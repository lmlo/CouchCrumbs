module CouchCrumbs
  
  # Based on the raw JSON that make up each view in a design doc.
  #
  class View
    
    include CouchCrumbs::Query
    
    attr_accessor :raw
  
    # Return or create a new view
    #
    def initialize(json)
      self.raw = JSON.parse(json)
    end
  
    # Return a new view (essentially just the raw JSON)
    #
    def self.basic(type, property)
      # Read the 'simple' template
      template = File.read(File.join(File.dirname(__FILE__), "templates", "basic.js"))
    
      template.gsub!(/\#name/, property.to_s.downcase)
      template.gsub!(/\#type/, type.to_s)
      template.gsub!(/\#property/, property.to_s.downcase)
    
      new(template)
    end
    
    # Return an advanced view
    #
    def self.advanced(template, opts = {})
      # Read the 'simple' template
      template = File.read(template)
      
      opts.each do |key, value|
        template.gsub!(/\##{ key }/, value)
      end
      
      new(template)
    end
    
    # Return a unique hash of the raw json
    #
    def hash
      raw.hash
    end
    
  end

end