require File.dirname(__FILE__) + '/spec_helper.rb'

describe CouchCrumbs do

  describe "#connect" do
    
    it "should connect to a default server" do
      CouchCrumbs.connect.should_not be_nil
    end
    
  end
  
end
