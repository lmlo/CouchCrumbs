require File.dirname(__FILE__) + '/../spec_helper.rb'

module CouchCrumbs
  
  class Resource
    
    include CouchCrumbs::Document
    
    property :name
    
    def after_initialize
      true
    end
    
    def before_create
      true
    end
    
    def after_create
      true
    end
    
    def before_save
      true
    end
    
    def after_save
      true
    end
    
    def before_destroy
      true
    end
    
    def after_destroy
      true
    end
    
  end
  
  class AlternateResource
    
    include CouchCrumbs::Document
    
    property :position
    
    use_database :alternate_database
    
  end
  
  describe Document do

    describe "(class)" do
      
      describe "#database" do
        
        before do
          @database = Resource.database
        end
        
        it "should return the active class-level database (or a default)" do
          @database.name.should eql(CouchCrumbs::default_database.name)
        end
        
      end
      
      describe "#use_database" do
        
        before do
          @alternate = Database.new(:name => "alternate_database")
        end
        
        it "should allow class specific databases" do
          Resource.database.name.should eql(CouchCrumbs::default_database.name)
          
          Resource.use_database(@alternate.name)
          
          Resource.database.name.should eql(@alternate.name)
        end
        
        it "should allow class specific databases" do
          AlternateResource.new.database.name.should eql(@alternate.name)
        end
        
        after do
          Resource.use_database(CouchCrumbs::default_database.name)
        end
        
      end
      
      describe "#property" do
        
        before do
          @resource = Resource.create(:name => "Sleepy")
        end
        
        it "should add a named property" do
          Resource.properties.should eql([:name])
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

      describe "#all" do
        
        it "should return all documents of type"
        
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
      
      describe "#update_attributes" do
        
        before do
          @resource = Resource.create(:name => "one")
          
          @resource.update_attributes(:name => "two")
        end
        
        it "should update the named properties" do
          Resource.get!(@resource.id).name.should eql("two")          
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
    
    describe "(callbacks)" do
      
      before(:each) do
        @resource = Resource.new
        
        # Remove the #freeze method to allow specs to run.
        @resource.stub!(:freeze)
      end
      
      describe "#after_initialize" do
                
        it "should be called"
        
      end
      
      describe "#before_create" do
        
        it "should be called"
        
      end
      
      describe "#after_create" do
        
        it "should be called"
        
      end
      
      describe "#before_save" do
        
        before do
          @resource.should_receive(:before_save).once
        end
        
        it "should be called" do
          @resource.save
        end
        
        after do
          @resource.destroy!
        end
        
      end
      
      describe "#after_save" do
        
        before do
          @resource.should_receive(:after_save).once
        end
        
        it "should be called" do
          @resource.save
        end
        
        after do
          @resource.destroy!
        end
                
      end
      
      describe "#before_destroy" do
        
        before do
          @resource.should_receive(:before_destroy).once
        end
        
        it "should be called" do
          @resource.destroy!
        end

      end
      
      describe "#after_destroy" do
        
        before do
          @resource.should_receive(:after_destroy).once
        end
        
        it "should be called" do
          @resource.destroy!
        end
        
      end
            
    end
        
  end
  
end
