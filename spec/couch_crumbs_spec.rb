require File.dirname(__FILE__) + '/spec_helper.rb'

describe CouchCrumbs do

  describe "#connect" do
    
    it "should attempt to connect to a default server" do
      status = CouchCrumbs.connect()
      
      status[:success].should be_true
      status[:server].should be_kind_of(CouchCrumbs::Server)
      status[:database].should be_kind_of(CouchCrumbs::Database)
    end
    
  end
  
end
