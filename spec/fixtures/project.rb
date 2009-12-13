class Project
  
  include CouchCrumbs::Document
  
  property :name
  
  parent_document :person
  
end
