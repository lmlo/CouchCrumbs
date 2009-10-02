require File.dirname(__FILE__) + '/../spec_helper.rb'

module CouchCrumbs
  
  describe Database do
  
    before do
      @server = Server.new
    end
    
    describe "#initialize" do

      it "should create a new database" do
        Database.new(@server, :name => "database_#{ rand(1_000_000) }").should be_kind_of(Database)
      end
      
      it "should return an existing database"
      
    end
    
    describe "#destroy" do
      
      before do
        Database.new(@server, :name => "destroy").destroy
      end
      
      it "should destroy a database" do        
        @server.databases.collect{ |db| db.name }.should_not include("destroy")
      end
      
    end
    
    after(:each) do
      @server.databases.destroy!
    end
    
  end
  
end
