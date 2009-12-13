class Address
  
  include CouchCrumbs::Document
  
  use_database :alternate_database
  
  property :location
  
  parent_document :person
   
end
