require File.dirname(__FILE__) + '/spec_helper.rb'

describe CouchCrumbs do

  describe "#connect" do
    
    before do
      CouchCrumbs.connect.should be_true
    end
    
    it "should attempt to connect to a default server and database" do
      CouchCrumbs.default_server.should be_kind_of(CouchCrumbs::Server)
      CouchCrumbs.default_database.should be_kind_of(CouchCrumbs::Database)
    end
    
  end
  
  describe "#get!" do
    
    it "should return a document"
    
  end
  
end
