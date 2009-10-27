require "facets/string/modulize"

module CouchCrumbs
  
  # Document is an abstract base module that you mixin to your own classes
  # to gain access to CouchDB document instances.
  #
  module Document
    
    # Mixin our document methods
    #
    def self.included(base)
      base.extend(ClassMethods)
      base.class_eval do
        # Accessors
        attr_accessor :uri, :raw
        
        # Override document #initialize
        def initialize(opts = {})
          raise ArgumentError.new("opts must be hash-like: #{ opts }") unless opts.respond_to?(:[])

          # If :json is present, we just parse it as an existing document
          if opts[:json]
            self.raw = JSON.parse(opts[:json])
          else
            self.raw = {}
            
            # Init special values
            raw["_id"] = opts[:id] || database.server.uuids
            raw["_rev"] = opts[:rev] unless opts[:rev].eql?(nil)
            raw["type"] = self.class.name.split('::').last
            raw["created_at"] = Time.now if self.class.properties.include?(:created_at)
            
            # Init named properties
            opts.each_pair do |name, value|
              send("#{ name }=", value)
            end
          end
          
          # This specific CouchDB document URI
          self.uri = File.join(database.uri, id)
        end
        
      end
      base.send(:include, InstanceMethods)
    end
            
    module ClassMethods
      
      # Return the database to use for this class
      #
      def database
        class_variable_set(:@@database, CouchCrumbs::default_database) unless class_variable_defined?(:@@database)
        
        class_variable_get(:@@database)
      end
      
      # Set the database that documents of this type will use (will create
      # a new database if name does not exist)
      #
      def use_database(name)
        class_variable_set(:@@database, Database.new(:name => name))
      end
      
      # Return all named properties for this document type
      #
      def properties
        class_variable_set(:@@properties, []) unless class_variable_defined?(:@@properties)
        
        class_variable_get(:@@properties) || []
      end
      
      # Add a named property to a document type
      #
      def property(name, opts = {})
        name = name.to_sym
        properties << name unless properties.include?(name) 
        
        class_eval do
          # getter
          define_method(name.to_sym) do
            raw[name.to_s]
          end
          # setter
          define_method("#{ name }=".to_sym) do |new_value|
            raw[name.to_s] = new_value
          end
        end
      end
            
      # Create and save a new document
      # @todo - add before_create and after_create callbacks
      #
      def create(opts = {})
        document = new(opts)

        yield document if block_given?
        
        document.save!

        document
      end
      
      # Return a specific document given an exact id
      #
      def get!(id)
        json = RestClient.get(File.join(database.uri, id))

        result = JSON.parse(json)

        document = new(
          :json => json
        )

        document
      end
            
      # Create a default view on a given property
      #
      def simple_view(*args)
        doc_type = name.split('::').last
        
        # Get the design doc for this document type
        design = Design.new(database, :name => doc_type.downcase)
        
        # Create simple views for the named properties
        args.each do |property|
          design.append_view(View.simple(doc_type, property))
          
          self.class.instance_eval do
            define_method("by_#{ property }".to_sym) do
              JSON.parse(RestClient.get("#{ design.uri }/_view/#{ property }".downcase))["rows"].collect do |row|                
                get!(row["id"])
              end
            end
          end
        end
          
        # Save the design doc
        design.save!
                
        nil
      end
      
      #=======================================================================
      
      # Link to a JavaScript file to use as a permanent view
      #
      def advanced_view(file_name, opts = {})
        
      end

      # Like belongs_to :parent
      #
      def parent_document(model, opts = {})
        property("#{ model }_parent_id")
        
        parent_class = eval(model.to_s.modulize)
        
        self.class_eval do
          define_method(model.to_sym) do
            parent_class.get!(raw["#{ model }_parent_id"])
          end
          
          define_method("#{ model }=".to_sym) do |new_parent|
            raise ArgumentError.new("parent documents must be saved before children") if new_parent.new_document?
            
            raw["#{ model }_parent_id"] = new_parent.id 
          end
        end
      end
      
      # Like has_one :child
      #
      def child_document(model, opts = {})
        
      end
      
      # Like has_many :children
      #
      def child_documents(models, opts = {})

      end
      
      # Like has_and_belongs_to_many :cousins
      #
      def related_documents(model, opts = {})
        
      end
      
      # Append default timestamps as named properties
      # @todo - add :created_at as a read-only property
      #
      def timestamps!
        [:created_at, :updated_at].each do |name|
          property(name)
        end
      end
            
      # @todo validation methods
      #
      def validates_with_method(method_name)

      end
      
      #=======================================================================
      
    end
    
    module InstanceMethods
      
      # Return the class-based database
      def database
        self.class.database
      end
      
      # Return document id (typically a UUID)
      #
      def id
        raw["_id"]
      end
      
      # Set the document id
      def id=(new_id)
        raise "only new documents may set an id" unless new_document?
        
        raw["_id"] = new_id
      end
      
      # Return document revision
      #
      def rev
        raw["_rev"]
      end
      
      # Return the CouchCrumb document type
      #
      def type
        raw["type"]
      end
      
      # Save a document to a database
      #
      def save!
        raise "unable to save frozen documents" if frozen?
        
        # Before Callback
        before_save if respond_to?(:before_save)
        
        # Update timestamps
        raw["updated_at"] = Time.now if self.class.properties.include?(:updated_at)
        
        # Save to the DB
        result = JSON.parse(RestClient.put(uri, raw.to_json))
        
        # Update ID and Rev properties
        raw["_id"] = result["id"]
        raw["_rev"] = result["rev"]
        
        # After callback
        after_save if respond_to?(:after_save)
        
        result["ok"]
      end
    
      # Update and save the named properties
      #
      def update_attributes(attributes = {})
        attributes.each_pair do |key, value|
          raw[key.to_s] = value
        end
        
        save!
      end
      
      # Return true prior to document being saved
      #
      def new_document?
        raw["_rev"].eql?(nil)
      end
      
      # Remove document from the database
      #
      def destroy!
        before_destroy if respond_to?(:before_destroy)

        freeze
        
        # destruction status
        status = nil
        
        # Since new documents haven't been saved yet, and frozen documents
        # *can't* be saved, simply return true here.
        if new_document?
          status = true
        else
          result = JSON.parse(RestClient.delete(File.join(uri, "?rev=#{ rev }")))
  
          status = result["ok"]
        end
        
        after_destroy if respond_to?(:after_destroy)
        
        status
      end
      
    end
    
  end
  
end
