require File.dirname(__FILE__) + '/../spec_helper.rb'

module CouchCrumbs
  
  class Person
    
    include CouchCrumbs::Document
    
    property :name
    
  end

  describe Query do
   
    include CouchCrumbs::Query
    
    before do
      @database = CouchCrumbs::default_database
    end
    
    describe "#query" do
      
      it "should query a database or view" do
        _query(File.join(@database.uri, "_all_docs")).should be_kind_of(Array)
      end

    end
    
  end
  
end