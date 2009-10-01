require File.dirname(__FILE__) + '/../spec_helper.rb'

module CouchCrumbs
  
  describe Server do
  
    describe "#initialize" do

      it "should return a server connection" do
        Server.new.should be_kind_of(Server)
      end
      
      it "should support an optional :uri argument" do
        Server.new(:uri => Server::DEFAULT_URI).should be_kind_of(Server)
      end
      
    end
  
    describe "#status" do
      
      before do
        @server = Server.new
      end
      
      it "should have the current status" do
        @server.status.should_not be_empty
      end
    
    end
    
    describe "#databases" do
      
      before do
        @server = Server.new
      end
      
      it "should return an array of databases" do
        @server.databases.each do |database|
          database.should be_kind_of(Database)
        end
      end
      
      after do
        @server.databases.destroy!
      end
      
    end
    
  end

end