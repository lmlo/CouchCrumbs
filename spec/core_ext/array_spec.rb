require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Array do
  
  context "#destroy!" do
    
    before do
      @object = mock(:object)
      
      @array.stub!(:all).and_return([@object])
    end
    
    it "should destroy all" do
      @object.should_receive(:destroy).once
      
      @array.all.destroy!
    end
  
  end
  
end
