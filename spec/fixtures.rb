class Resource
  
  include CouchCrumbs::Document
  
  property :name
  
end

class Person
  
  attr_accessor :callbacks
  
  include CouchCrumbs::Document
  
  property :name
  property :title
  
  timestamps!
  
  has_one :address
  
  simple_view :name

  advanced_view :name => "title", :template => File.join("spec", "couch_crumbs", "templates", "person_title.js")
    
  def after_initialize
    self.callbacks = [:after_initialize]
  end
  
  def before_create
    self.callbacks << :before_create
  end
  
  def after_create
    self.callbacks << :after_create
  end
  
  def before_save
    self.callbacks << :before_save
  end
  
  def after_save
    self.callbacks << :after_save
  end
  
  def before_destroy
    self.callbacks << :before_destroy
  end
  
  def after_destroy
    self.callbacks << :after_destroy
  end
  
end

class Address
  
  include CouchCrumbs::Document
  
  use_database :alternate_database
  
  property :location
  
  belongs_to :person
   
end