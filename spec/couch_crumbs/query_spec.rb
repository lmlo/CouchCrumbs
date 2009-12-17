require File.dirname(__FILE__) + '/../spec_helper.rb'

module CouchCrumbs

  describe Query do
   
    include CouchCrumbs::Query
    
    before do
      @database = CouchCrumbs::default_database
      
      # Ensure we have at least a few documents
      3.times do
        Person.create!(:name => rand(1_000_000).to_s)
      end
    end
    
    describe "#query_docs" do
      
      before do        
        @docs = query_docs(File.join(@database.uri, "_all_docs"))
      end
      
      it "should query a database or view for docs" do
        @docs.each do |doc|
          doc.should be_kind_of(Hash)
        end
      end
      
    end
    
    describe "#query_values" do
      
      before do
        @view = Person.design_doc.views(:name => "count")
      end
      
      it "should query a view for value results" do        
        query_values(@view.uri).should be_kind_of(Integer)
      end
      
    end
    
  end
  
end