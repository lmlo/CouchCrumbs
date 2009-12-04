require File.dirname(__FILE__) + '/../spec_helper.rb'

module CouchCrumbs
  
  describe View do
    
    describe "#initialize" do
      
      it "should initialize a new view"
      
    end
    
    describe "#create!" do
      
      it "should initialize a view and save to the containing design_doc"
      
    end
    
    describe "#simple" do
            
      it "should return a simple JSON view" do
        View.simple(Person.crumb_type, :name).should be_kind_of(String)
      end
            
    end
    
    describe "#advanced" do
      
      before do
        @view = View.advanced(File.join("lib", "couch_crumbs", "templates", "all.js"), :type => Person.crumb_type)
      end
      
      it "should return advanced raw JSON" do
        @view.should be_kind_of(String)
      end
      
    end
    
  end
  
end
