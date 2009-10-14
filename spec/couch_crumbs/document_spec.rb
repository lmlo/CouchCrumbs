require File.dirname(__FILE__) + '/../spec_helper.rb'

module CouchCrumbs
  
  class Resource     
    
    include CouchCrumbs::Document
    
    property :name
    
  end
  
  describe Document do

    describe "(class)" do
      
      describe "#property" do
        
        before do
          @resource = Resource.create(:name => "Sleepy")
        end
        
        it "should add a named property accessor" do          
          @resource.name.should eql("Sleepy")
        end
        
        it "should persist named properties" do                   
          Resource.get!(@resource.id).name.should eql("Sleepy")
        end
        
        after do
          @resource.destroy!
        end
        
      end
            
      describe "#timestamps!" do

      end

      describe "#view_with" do
        
        it "should link a JavaScript document as a permanent view"
      
      end
    
      describe "#parent_document" do
      
        it "should relate a parent document"
        
      end
    
      describe "#child_document" do
        
        it "should relate a single child document"
        
      end
    
      describe "#child_documents" do
        
        it "should relate multiple child documents"
        
      end
      
      describe "#related_documents" do
        
        it "should relate many documents to many documents"
        
      end

      describe "#validates_with_method" do
      
      end
      
      
      describe "#create" do
        
        it "should create a new document" do          
          @resource = Resource.create
          
          @resource.id.should_not be_empty
          @resource.rev.should_not be_empty
          @resource.should be_kind_of(Resource)
        end
        
        after do
          @resource.destroy!
        end
        
      end
      
      describe "#get!" do
        
        before do
          @resource = Resource.create
        end
        
        it "should instantiate a specific document given an id" do
          Document.get!(@resource.id).id.should eql(@resource.id)
        end
        
        after do
          @resource.destroy!
        end
        
      end
      
    end
    
    describe "(instance)" do
      
      describe "#initialize" do
        
        before do
          @resource = Resource.new
        end
        
        it "should have an id" do
          @resource.id.should match(/[a-z0-9]{32}/i)
        end
        
        it "should have a type" do
          @resource.type.should eql("Resource")
        end
        
      end

      describe "#save" do
        
        before do
          @resource = Resource.new
        end
        
        it "should save a document to a database" do          
          @resource.save.should be_true
        end
        
        after do          
          @resource.destroy!
        end
        
      end
      
      describe "#new_document?" do
        
        before do
          @resource = Resource.new
        end
        
        it "should return true prior to a document being saved" do
          @resource.new_document?.should be_true
        end
        
      end
      
      describe "#destroy!" do
        
        before do
          @resource = Resource.create
        end
        
        it "should destroy document" do          
          @resource.destroy!.should be_true
          @resource.frozen?.should be_true
          
          lambda do
            Resource.get!(@resource.id)
          end.should raise_error(RestClient::ResourceNotFound)
        end
        
      end
    
    end
        
  end
  
end
