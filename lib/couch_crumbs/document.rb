require "validatable"

module CouchCrumbs
  
  # Document is an abstract base module that you mixin to your own classes.
  #
  module Document
    
    def self.included(base)
      base.extend(ClassMethods)
      base.class_eval do
        
        attr_accessor :uri, :raw
        
        # Override document #initialize
        def initialize(opts = {})
          raise ArgumentError.new("opts must be hash-like: #{ opts }") unless opts.respond_to?(:[])

          # If :json is present, we just parse it as an existing document
          if opts[:json]
            self.raw = JSON.parse(opts[:json])
          else
            self.raw = {}
            
            self.raw["_id"] = opts[:id] || database.server.uuids
            self.raw["_rev"] = opts[:rev] unless opts[:rev].eql?(nil)
            # New documents need to have a 'type' set
            self.raw["type"] = self.class.name.split('::').last

            # @todo - turn all opts keys into symbols (to grab HTML inputs)
            
            # Init named properties
            self.class.properties.each do |name|
              self.raw[name.to_s] = opts[name]
            end
          end
          
          # The specific CouchDB URI
          self.uri = File.join(database.uri, id)
        end

      end
      base.send(:include, InstanceMethods)
    end
    
    # Return a specific document type given an exact id (from the 
    # default_database)
    #
    def self.get!(id)
      json = RestClient.get(File.join(CouchCrumbs::default_database.uri, id))
      
      result = JSON.parse(json)
      
      # Eval with basic filtering (trusting your database)
      document = eval(result["type"].gsub(/\W/i, '')).new(
        :json => json
      )

      document
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

      # Create and save a new document
      # @todo - add before_create and after_create callbacks
      #
      def create(opts = {})
        document = new(opts)

        yield document if block_given?

        document.save

        document
      end
      
      # Add a named property to a document type
      #
      def property(name, opts = {})
        self.properties << name.to_sym
        
        class_eval do
          # getter
          define_method(name.to_sym) do
            self.raw[name.to_s]
          end
          # setter
          define_method("#{ name }=".to_sym) do |new_value|
            self.raw[name.to_s] = new_value
          end
        end
      end
      
      # Return all named properties for this document type
      #
      def properties
        @@properties ||= []
      end
      
      #=======================================================================
      
      # Retrieve all documents of type
      def all
        []
      end
      
      # Create a default view on a given property
      def view_by(property, opts = {})
        
      end
      
      # Link to a JavaScript file to use as a permanent view
      #
      def view_with(name, opts = {})

      end

      # Like belongs_to :parent
      #
      def parent_document(model, opts = {})

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
      #
      def timestamps!

      end
      
      # @todo life cycle callbacks
      
      def save_callback(target, opts = {})
        
      end
      
      # @todo validation methods
      
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
      # @todo - add before_save and after_save callbacks
      def save
        raise "unable to save frozen documents" if frozen?

        before_save if respond_to?(:before_save)
        
        result = JSON.parse(RestClient.put(uri, self.raw.to_json))

        self.raw["_id"] = result["id"]
        self.raw["_rev"] = result["rev"]
        
        after_save if respond_to?(:after_save)
        
        result["ok"]
      end
    
      # Update and save the named properties
      #
      def update_attributes(attributes = {})
        attributes.each_pair do |key, value|
          self.raw[key.to_s] = value
        end
        
        save
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
          result = JSON.parse(RestClient.delete(File.join(uri, "?rev=#{ self.rev }")))
  
          status = result["ok"]
        end
        
        after_destroy if respond_to?(:after_destroy)
        
        status
      end
      
    end
    
  end
  
end
