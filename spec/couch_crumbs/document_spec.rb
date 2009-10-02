require File.dirname(__FILE__) + '/../spec_helper.rb'

module CouchCrumbs
  
  describe Document do

    describe "(class)" do
      
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
      
      describe "#create" do
        
        it "should create a new document" do          
          @document = Document.create
          
          @document.id.should_not be_empty
          @document.rev.should_not be_empty
        end
        
      end
      
      describe "#get!" do
        
        before do
          @document = Document.create
        end
        
        it "should instantiate a specific document given an id" do
          Document.get!(@document.id).id.should eql(@document.id)
        end
        
      end
      
    end
    
    describe "(instance)" do
      
      describe "#initialize" do
        
        it "should have an id" do
          Document.new.id.should match(/[a-z0-9]{32}/i)
        end
      
      end
      
      describe "#save" do
        
        it "should save a document to a database" do          
          Document.new.save.should be_true
        end
        
      end
      
      describe "#new_document?" do
        
        before do
          @document = Document.new
        end
        
        it "should return true prior to a document being saved" do
          @document.new_document?.should be_true
        end
        
      end
      
    end
        
  end
  
end
