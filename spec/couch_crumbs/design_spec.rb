require File.dirname(__FILE__) + '/../spec_helper.rb'

module CouchCrumbs
    
  describe Design do
    
    before do
      @database = CouchCrumbs::default_database  
    end
    
    describe "#get!" do
      
      it "should find or create a design document" do
        Design.get!(@database, :name => "get").should be_kind_of(Design)
      end
      
    end
    
    describe "#initialize" do
      
      before do
        @design = Design.get!(@database, :name => "example")
      end
      
      it "should create a new design document" do
        @design.should be_kind_of(Design)
      end
      
      it "should have an id property" do        
        @design.id.should eql("_design/example")
      end
    
      it "should have a name property" do
        @design.name.should eql("example")
      end
      
    end
    
    describe "#save!" do
    
      before do        
        @design = Design.new(@database, :name => "save")
                
        @design.save!
      end
    
      it "should have a revision property" do
        @design.rev.should_not be_nil
      end
      
      after do        
        @design.destroy!
      end
    
    end
    
    describe "#destroy!" do
      
      before do
        @design = Design.get!(@database, :name => "destroy")
      end
      
      it "should destroy the design document" do
        @design.destroy!.should be_true
      end
      
    end
    
    describe "#views" do
      
      before do
        # Grab the design doc from the Person class declared above
        @design = Design.get!(@database, :name => "person")
      end
      
      it "should return an array of views" do
        @design.views.should_not be_empty
      end
      
      it "should support an optional name parameter to single a specific view" do        
        @design.views(:name => "all").should be_kind_of(View)
      end
      
    end
    
    describe "#add_view" do
      
      before do
        # Manually construct a design doc and view on Person
        @design = Design.get!(@database, :name => "append")
                
        @view = View.create!(@design, "title", View.simple_json(Person.crumb_type, :title))
      end
      
      it "should append a view to the list of views" do
        @design.views.collect{ |v| v.hash }.should eql([@view.hash])
      end
      
    end
    
  end
  
end
