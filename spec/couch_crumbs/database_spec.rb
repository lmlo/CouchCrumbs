require File.dirname(__FILE__) + '/../spec_helper.rb'

module CouchCrumbs
  
  describe Database do
        
    describe "#initialize" do

      it "should create a new database" do
        Database.new.should be_kind_of(Database)
      end
      
      it "should return an existing database"
      
    end
    
    describe "#documents" do
      
      before do
        @database = CouchCrumbs::default_database

        @database.documents.destroy!
      
        @document = Document.create
      end
      
      it "should return an array of all documents" do
        @database.documents.collect{ |doc| doc.id }.should eql([@document.id])
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
