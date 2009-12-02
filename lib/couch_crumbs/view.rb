module CouchCrumbs
  
  # Based on the raw JSON that make up each view in a design doc.
  #
  class View
    
    include CouchCrumbs::Query
    
    attr_accessor :raw, :name, :uri
  
    # Return or create a new view object
    #
    def initialize(design, name, json)
      self.name = name
      self.uri = File.join(design.uri, "_view", name)
      self.raw = JSON.parse(json)
    end
  
    # Return a view as a JSON hash
    #
    def self.simple(type, property)
      # Read the 'simple' template (stripping newlines and tabs)
      template = File.read(File.join(File.dirname(__FILE__), "templates", "basic.js")).gsub!(/(\n|\r|\t)/, '')
    
      template.gsub!(/\#name/, property.to_s.downcase)
      template.gsub!(/\#type/, type.to_s)
      template.gsub!(/\#property/, property.to_s.downcase)
      
      JSON.parse(template)
    end
    
    # Return an advanced view as a JSON hash 
    # template => path to a .js template
    # opts => options to gsub into the template
    #
    def self.advanced(template, opts = {})
      # Read the given template (strip newlines to avoid JSON parser errors)
      template = File.read(template).gsub!(/(\n|\r|\t)/, '')
      # Sub in any opts
      opts.each do |key, value|
        template.gsub!(/\##{ key }/, value.to_s)
      end
      
      JSON.parse(template)
    end
    
    # Return a unique hash of the raw json
    #
    def hash
      raw.hash
    end
    
  end

end