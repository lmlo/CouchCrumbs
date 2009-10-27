require File.dirname(__FILE__) + '/../spec_helper.rb'

module CouchCrumbs
  
  class Resource
    
    include CouchCrumbs::Document
    
    property :name
    
  end
  
  describe Database do
        
    before do
      @database = CouchCrumbs::default_database
    end
    
    describe "#initialize" do

      it "should create a new database" do
        Database.new.should be_kind_of(Database)
      end
      
      it "should return an existing database"
      
    end
    
    describe "#documents" do
      
      before do
        @resource = Resource.create
      end
      
      it "should return an array of all documents" do
        @database.documents.collect{ |doc| doc.id }.should include(@resource.id)
      end
      
      it "should support optional view parameters" do
        @database.documents(:key => @resource.id).collect{ |d| d.id }.should eql([@resource.id])
      end
      
      after do
        @database.documents.destroy!
      end
      
    end
    
    describe "#design_documents" do
      
      before do        
        @design = Design.new(@database, :name => "spec")
      end
      
      it "should return an array of design documents" do                
        @database.design_documents.collect{ |d| d.rev }.should include(@design.rev)
      end
      
    end
    
    describe "#destroy!" do
      
      before do
        Database.new(:name => "destroy").destroy!
      end
      
      it "should destroy a database" do
        CouchCrumbs::default_server.databases.collect{ |db| db.name }.should_not include("destroy")
      end
      
    end
    
  end
  
end
