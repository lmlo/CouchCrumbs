require File.dirname(__FILE__) + '/../spec_helper.rb'

module CouchCrumbs
  
  describe Document do
    
    before do
      @server = Server.new
      
      @database = Database.new(@server, :name => "document_specs")
    end
    
    describe "(class methods)" do
      
      describe "#property" do
      
      end
    
      describe "#view_by" do
      
      end
    
      describe "#has_many" do
      
      end
    
      describe "#belongs_to" do
      
      end
    
      describe "#timestamps!" do
      
      end
    
      describe "#save_callback" do
      
      end
    
      describe "#validates_with_method" do
      
      end
    
    end
        
  end
  
end
