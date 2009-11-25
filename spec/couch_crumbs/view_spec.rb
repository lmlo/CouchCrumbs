require File.dirname(__FILE__) + '/../spec_helper.rb'

module CouchCrumbs
  
  class Person
    
    include CouchCrumbs::Document
    
    property :name
    
    view_by :name

  end
  
  describe View do
        
    describe "#basic" do
      
      it "should return a simple view" do
        View.basic(Person, :name).should be_kind_of(View)
      end
            
    end
    
    describe "#hash" do
      
      before do
        @view = View.basic(Person, :name)
      end
      
      it "should return a hash value for the raw JSON" do
        @view.hash.should eql(@view.raw.hash)
      end
      
    end
    
  end
  
end
