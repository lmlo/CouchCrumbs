require File.dirname(__FILE__) + '/../spec_helper.rb'

module CouchCrumbs
  
  class Person
    
    include CouchCrumbs::Document
    
    property :name
    property :title
        
    simple_view :name
    
  end
  
  describe Design do
    
    before do
      @database = CouchCrumbs::default_database  
    end
    
    describe "#initialize" do
      
      before do
        @design = Design.new(@database, :name => "example")
      end
      
      it "should create a new design document" do
        @design.should be_kind_of(Design)
      end
      
      it "should have an id property" do
        @design.id.should eql("_design/example")
      end
      
      it "should have a revision property" do
        @design.rev.should_not be_nil
      end
      
      it "should have a name property" do
        @design.name.should eql("example")
      end
      
    end
        
    describe "#save!" do
    
      before do
        @design = Design.new(@database, :name => "save")
      end
      
      it "should save a design document to the database" do
        @design.save!.should be_true
      end
      
    end
    
    describe "#destroy!" do
      
      before do
        @design = Design.new(@database, :name => "destroy")
      end
      
      it "should destroy the design document" do
        @design.destroy!.should be_true
      end
      
    end
    
    describe "#views" do
      
      before do                
        # Grab the design doc from the Person class declared above
        @design = Design.new(@database, :name => "person")
      end
      
      it "should return an array of views" do        
        @design.views.should_not be_empty
      end
      
    end
    
    describe "#append_view" do
      
      before do
        # Manually construct a design doc and view on Person
        @design = Design.new(@database, :name => "append")
        
        @view = View.simple(Person, :title)
        
        @design.append_view(@view)
      end
      
      it "should append a view to the list of views" do
        @design.views.collect{ |v| v.hash }.should eql([@view.hash])
      end
      
    end
    
  end
  
end
