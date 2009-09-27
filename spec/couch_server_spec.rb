require File.dirname(__FILE__) + '/spec_helper.rb'

describe CouchServer do
  
  describe "#default_server_uri" do
  
    it "should return a sensible URI for connecting to an operating CouchDB server" do
      CouchServer::default_server_uri.should_not be_empty
    end
  
  end

  describe "#default_database" do
  
    it "should return a stock database name" do
      CouchServer::default_database.should_not be_empty
    end
  
  end

  describe "#initialize" do
  
    it "should raise an error unless opts include a :server URI" do
      lambda do
        CouchServer.new({})
      end.should raise_error(/server URI/)
    end

    it "should return a new connection to a CouchDB server" do
      CouchServer.new(:server => CouchServer::default_server_uri).should_not be_nil
    end
  
  end
  
  describe "#status" do
    
    it "should have the current status" do
      
    end
    
  end
  
end
