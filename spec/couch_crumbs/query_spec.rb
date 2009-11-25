require File.dirname(__FILE__) + '/../spec_helper.rb'

module CouchCrumbs
  
  class Person
    
    include CouchCrumbs::Document
    
    property :name
    
  end

  describe Query do
   
    before do
      @database = CouchCrumbs::default_database
    end
    
    describe "#query" do
            
      it "should query a database or view"

    end
    
  end
  
end