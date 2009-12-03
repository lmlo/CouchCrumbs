require File.dirname(__FILE__) + '/../spec_helper.rb'

module CouchCrumbs
  
  describe View do
        
    describe "#basic" do
            
      it "should return a simple view" do
        View.simple(Person.crumb_type, :name).should be_kind_of(Hash)
      end
            
    end
    
    describe "#advanced" do
      
      before do
        @view = View.advanced(File.join("lib", "couch_crumbs", "templates", "all.js"), :type => Person.crumb_type)
      end
      
      it "should return a hash value for the raw JSON" do
        @view.should be_kind_of(Hash)
      end
      
    end
    
  end
  
end
