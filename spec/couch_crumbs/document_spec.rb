require File.dirname(__FILE__) + '/../spec_helper.rb'

module CouchCrumbs
  
  describe Document do

    describe "(class)" do
      
      describe "#database" do
        
        before do
          @database = Person.database
        end
        
        it "should return the active class-level database (or a default)" do
          @database.name.should eql(CouchCrumbs::default_database.name)
        end
        
      end
      
      describe "#use_database" do
        
        before do
          @address = Database.new(:name => "alternate_database")
        end
        
        it "should allow class specific databases" do
          Person.database.name.should eql(CouchCrumbs::default_database.name)
          
          Person.use_database(@address.name)
          
          Person.database.name.should eql(@address.name)
        end
        
        it "should allow class specific databases" do
          Address.new.database.name.should eql(@address.name)
        end
        
        after do
          Person.use_database(CouchCrumbs::default_database.name)
        end
        
      end
      
      describe "#property" do
        
        before do
          @person = Person.create!(:name => "Sleepy")
        end
        
        it "should add a named property" do
          Person.properties.should include(:name)
        end
        
        it "should add a named property accessor" do
          @person.name.should eql("Sleepy")
        end
        
        it "should persist named properties" do
          Person.get!(@person.id).name.should eql("Sleepy")
        end
        
        after do
          @person.destroy!
        end
        
      end
            
      describe "#timestamps!" do
        
        it "should add created_at and updated_at properties" do          
          [:created_at, :updated_at].each do |property|
            Person.properties.should include(property)
          end
        end
        
      end
      
      describe "#design_doc" do
        
        it "should return the design doc for the given class" do
          Person.design_doc.should be_kind_of(Design)
        end
        
      end
      
      describe "views" do
        
        it "should return an array of all views defined for this class" do
          Person.views.should be_kind_of(Array)
        end
        
      end
      
      describe "#simple_view" do
        
        before do
          @steve = Person.create!(:name => "Steve")
        end
        
        it "should create an appropriate view" do
          Person.by_name.collect{ |p| p.rev }.should eql([@steve.rev])
        end
        
        after do
          @steve.destroy!
        end
        
      end
      
      describe "#advanced_view" do
        
        before do
          @steve = Person.create!(:name => "Steve", :title => "CEO")
        end
        
        it "should create an appropriate advanced view" do          
          Person.by_title.collect{ |p| p.title }.should eql([@steve.title])
        end
        
        after do
          @steve.destroy!
        end
        
      end
      
      describe "#create!" do
        
        it "should create a new document" do
          @person = Person.create!
      
          @person.id.should_not be_empty
          @person.rev.should_not be_empty
          @person.should be_kind_of(Person)          
          @person.created_at.strftime("%Y-%m-%d %H:%M").should eql(Time.now.strftime("%Y-%m-%d %H:%M"))
        end
        
        after do
          @person.destroy!
        end
        
      end
      
      describe "#belongs_to" do

        before do
          @person = Person.create!

          @address = Address.create!
        end

        it "should add a parent_id property" do
          Address.properties.should include(:person_parent_id)
        end

        it "should add a parent accessor" do
          @address.should respond_to(:person)
        end

        it "should add a parent= accessor" do
          @address.should respond_to(:person=)
        end

        it "should raise an error if parent has not been saved" do
          lambda do
            @address.person = Person.new
          end.should raise_error
        end

        it "should set the parent document" do
          @address.person = @person

          @address.save!

          @address.person.id.should eql(@person.id)
        end

      end
      
      describe "#has_one" do
        
        before do
          @person = Person.new

          @address = Address.new
        end
        
        it "should add a model_name_id property to parent class" do
          Person.properties.should include(:address_child_id)
        end
        
        it "should add a child accessor" do
          @person.should respond_to(:address)
        end
        
        it "should add a child= accessor" do
          @person.should respond_to(:address=)
        end
        
        it "should set the child document" do          
          @person.save!
          @address.save!
          
          @person.address = @address
          
          @person.address.id.should eql(@address.id)
        end
        
      end
      
    end
    
    describe "(instance)" do
      
      describe "#initialize" do
        
        before do
          @person = Person.new
        end
        
        it "should have an id" do
          @person.id.should match(/[a-z0-9]{32}/i)
        end
        
        it "should have a type" do
          @person.type.should eql("person")
        end
        
      end

      describe "#save!" do
        
        before do
          @person = Person.new
        end
        
        it "should save a document to a database" do
          @person.save!.should be_true
          @person.updated_at.strftime("%Y-%m-%d %H:%M").should eql(Time.now.strftime("%Y-%m-%d %H:%M"))
        end
        
        after do
          @person.destroy!
        end
        
      end
      
      describe "#update_attributes!" do
        
        before do
          @person = Person.create!(:name => "one")
          
          @person.update_attributes!(:name => "two")
        end
        
        it "should update the named properties" do
          Person.get!(@person.id).name.should eql("two")          
        end
        
        after do
          @person.destroy!
        end
        
      end
      
      describe "#new_document?" do
        
        before do
          @person = Person.new
        end
        
        it "should return true prior to a document being saved" do
          @person.new_document?.should be_true
        end
        
      end
      
      describe "#destroy!" do
        
        before do
          @person = Person.create!
        end
        
        it "should destroy document" do
          @person.destroy!.should be_true
          @person.frozen?.should be_true
          
          lambda do
            Person.get!(@person.id)
          end.should raise_error(RestClient::ResourceNotFound)
        end
        
      end
    
    end
    
    describe "(callbacks)" do
      
      before(:each) do
        @steve = Person.new
        
        # Remove the #freeze method to allow specs to run.
        @steve.stub!(:freeze)
      end
      
      describe "#after_initialize" do
                
        it "should be called" do
          @steve.callbacks.should include(:after_initialize)
        end
        
      end
      
      describe "#before_create" do
        
        before do          
          @bill = Person.create!
        end
        
        it "should be called" do
          @bill.callbacks.should include(:before_create)
        end
        
        after do
          @bill.destroy!
        end
        
      end
      
      describe "#after_create" do
      
        before do
          @bill = Person.create!
        end

        it "should be called" do
          @bill.callbacks.should include(:after_create)
        end
        
        after do
          @bill.destroy!
        end
        
      end
      
      describe "#before_save" do
        
        before do
          @steve.save!
        end
        
        it "should be called" do
          @steve.callbacks.should include(:before_save)
        end
        
        after do
          @steve.destroy!
        end
        
      end
      
      describe "#after_save" do
        
        before do
          @steve.save!
        end
        
        it "should be called" do
          @steve.callbacks.should include(:after_save)
        end
        
        after do
          @steve.destroy!
        end
                
      end
      
      describe "#before_destroy" do
        
        before do
          @steve.destroy!
        end
        
        it "should be called" do
          @steve.callbacks.should include(:before_destroy)
        end

      end
      
      describe "#after_destroy" do
        
        before do
          @steve.destroy!
        end
        
        it "should be called" do
          @steve.callbacks.should include(:after_destroy)
        end
        
      end
            
    end
    
    describe "(default views)" do
      
      describe "#all" do
        
        before do
          Person.all.destroy!
          
          @person = Person.create!
        end
        
        it "should return all documents of a certain type" do
          Person.all.collect{ |p| p.id }.should eql([@person.id])
        end
        
        after do
          @person.destroy!
        end
        
      end
      
    end
        
  end
  
end
