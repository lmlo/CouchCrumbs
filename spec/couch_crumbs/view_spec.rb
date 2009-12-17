require File.dirname(__FILE__) + '/../spec_helper.rb'

module CouchCrumbs
  
  describe View do

    describe "#simple_json" do
            
      it "should return a simple JSON view" do
        View.simple_json(Person.crumb_type, :name).should be_kind_of(String)
      end

    end
    
    describe "#advanced_json" do
      
      before do
        @view = View.advanced_json(File.join("lib", "couch_crumbs", "json", "all.json"), :crumb_type => Person.crumb_type)
      end
      
      it "should return advanced raw JSON" do
        @view.should be_kind_of(String)
      end
      
    end
    
    describe "#has_reduce?" do
      
      before do        
        @view = Person.design_doc.views(:name => "count")
      end
      
      it "should return true if the view has a reduce function" do
        @view.has_reduce?.should be_true
      end
      
    end
    
  end
  
end
