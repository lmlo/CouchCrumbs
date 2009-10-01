require File.dirname(__FILE__) + '/../spec_helper.rb'

module CouchCrumbs
  
  describe Database do
  
    before do
      @server = Server.new
    end
    
    describe "#initialize" do
      
      #it "should return an existing database" do
      #  @original = Database.new(@server, :name => "original")
      #  
      #  Database.new(@server, :name => "original").should be_eql(@original)
      #end
      
      it "should create a new database" do
        Database.new(@server, :name => "database_#{ rand(1_000_000) }").should be_kind_of(Database)
      end
      
    end
    
    describe "#destroy" do
      
      before do
        @database = Database.new(@server)
      end
      
      it "should destroy a database" do
        @database.destroy.should be_true
      end
      
    end
    
    after(:each) do
      @server.databases.destroy!
    end
    
  end
  
end
