class View
  
  attr_accessor :raw
  
  # Return or create a new view
  #
  def initialize(json)    
    self.raw = JSON.parse(json)
  end
  
  # Return a new view (essentially just the raw JSON)
  #
  def self.simple(type, property)
    # Read the 'simple' template
    template = File.read(File.join(File.dirname(__FILE__), "templates", "simple.js"))
    
    template.gsub!(/\#view_name/, property.to_s.downcase)
    template.gsub!(/\#view_type/, type.to_s)
    template.gsub!(/\#view_property/, property.to_s.downcase)
    
    new(template)
  end
  
  # Return a unique hash of the raw json
  #
  def hash
    raw.hash
  end
  
end
