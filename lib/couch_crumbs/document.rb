require "facets/string"
require "english/inflect"

module CouchCrumbs
  
  # Document is an abstract base module that you mixin to your own classes
  # to gain access to CouchDB document instances.
  #
  module Document
    
    module InstanceMethods
      
      include CouchCrumbs::Query
      
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
      def crumb_type
        raw["crumb_type"]
      end
      
      # Save a document to a database
      #
      def save!
        raise "unable to save frozen documents" if frozen?
        
        # Before Callback
        before_save
        
        # Update timestamps
        raw["updated_at"] = Time.now if self.class.properties.include?(:updated_at)
        
        # Save to the DB
        result = JSON.parse(RestClient.put(uri, raw.to_json))
        
        # Update ID and Rev properties
        raw["_id"] = result["id"]
        raw["_rev"] = result["rev"]
        
        # After callback
        after_save
        
        result["ok"]
      end
    
      # Update and save the named properties
      #
      def update_attributes!(attributes = {})
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
        before_destroy

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
        
        after_destroy
        
        status
      end
      
      # Hook called after a document has been initialized
      #            
      def after_initialize
        nil
      end
      
      # Hook called during #create! before a document is #saved!
      #
      def before_create
        nil
      end

      # Hook called during #create! after a document has #saved!
      #
      def after_create
        nil
      end

      # Hook called during #save! before a document has #saved!
      #
      def before_save
        nil
      end

      # Hook called during #save! after a document has #saved!
      #
      def after_save
        nil
      end

      # Hook called during #destroy! before a document has been destroyed
      #
      def before_destroy
        nil
      end

      # Hook called during #destroy! after a document has been destroyed
      #
      def after_destroy
        nil
      end
      
    end
    
    module ClassMethods
      
      include CouchCrumbs::Query
      
      # Return the useful portion of module/class type
      # @todo cache crumb_type on the including base class
      #
      def crumb_type
        class_variable_get(:@@crumb_type)
      end
      
      # Return the database to use for this class
      #
      def database
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
        class_variable_get(:@@properties)
      end
      
      # Add a named property to a document type
      #
      def property(name, opts = {})
        name = name.to_sym
        properties << name
                
        class_eval do
          # getter
          define_method(name) do
            raw[name.to_s]
          end
          # setter
          define_method("#{ name }=".to_sym) do |new_value|
            raw[name.to_s] = new_value
          end
        end
      end
      
      # Append default timestamps as named properties
      # @todo - add :created_at as a read-only property
      #
      def timestamps!
        [:created_at, :updated_at].each do |name|
          property(name)
        end
      end
      
      # Return the design doc for this class
      #
      def design_doc
        Design.get!(database, :name => crumb_type)
      end
      
      # Return an array of all views for this class
      #
      def views(opts = {})
        design_doc.views(opts)
      end
            
      # Create a default view on a given property
      #
      def simple_view(*args)
        # Get the design doc for this document type
        design = design_doc
        
        # Create simple views for the named properties
        args.each do |prop|
          view = View.create!(design, prop.to_s, View.simple_json(crumb_type, prop))
                    
          self.class.instance_eval do
            define_method("by_#{ prop }".to_sym) do |opts|
              query(view.uri, {:descending => false}.merge(opts||{})).collect do |row|
                if row["doc"]["crumb_type"]
                  new(:hash => row["doc"])
                end
              end
            end
          end
        end
        
        nil
      end
      
      # Create an advanced view from a given :template
      #
      def advanced_view(opts = {})
        raise ArgumentError.new("opts must contain a :name key") unless opts.has_key?(:name)
        raise ArgumentError.new("opts must contain a :template key") unless opts.has_key?(:template)
                
        view = View.create!(design_doc, opts[:name], View.advanced_json(opts[:template], opts))
                
        self.class.instance_eval do
          define_method("by_#{ opts[:name] }".to_sym) do
            query(view.uri, :descending => false).collect do |row|
              if row["doc"]["crumb_type"]
                new(:hash => row["doc"])
              end
            end
          end
        end
      end
      
      # Create and save a new document
      # @todo - add before_create and after_create callbacks
      #
      def create!(opts = {})
        document = new(opts)
        
        yield document if block_given?
        
        document.before_create
        
        document.save!
        
        document.after_create
        
        document
      end
      
      # Return a specific document given an exact id
      #
      def get!(id)
        raise ArgumentError.new("id must not be blank") if id.empty? or id.nil?
        
        json = RestClient.get(File.join(database.uri, id))

        result = JSON.parse(json)

        document = new(
          :json => json
        )

        document
      end
      
      # Return an array of all documents of this type
      #
      def all(opts = {})
        # Add the #all method
        view = design_doc.views(:name => "all")
      
        query("#{ view.uri }".downcase, opts).collect do |row|
          doc = row["doc"]
          
          if doc["crumb_type"]
            get!(doc["_id"])
          else
            warn "skipping unknown document: #{ doc }"
            nil
          end
        end
      end
      
      # Like parent_document :person
      #
      def parent_document(model, opts = {})
        model = model.to_s.downcase
        
        property("#{ model }_parent_id")
        
        begin
          parent_class = eval(model.modulize)
        rescue
          require "#{ model.methodize }.rb"
          retry
        end
                
        self.class_eval do
          define_method(model.to_sym) do
            parent_class.get!(raw["#{ model }_parent_id"])
          end
        
          define_method("#{ model }=".to_sym) do |new_parent|
            raise ArgumentError.new("parent documents must be saved before children") if new_parent.new_document?
        
            raw["#{ model }_parent_id"] = new_parent.id 
          end
        end
        
        nil
      end
          
      # Like child_document :address
      #
      def child_document(model, opts = {})
        model = model.to_s.downcase
        
        property("#{ model }_child_id")
        
        begin
          child_class = eval(model.modulize)
        rescue
          require "#{ model.methodize }.rb"
          retry
        end
        
        self.class_eval do
          define_method(model.to_sym) do
            child_class.get!(raw["#{ model }_child_id"])
          end
        
          define_method("#{ model }=".to_sym) do |new_child|
            raise ArgumentError.new("parent documents must be saved before adding children") if new_document?
            
            raw["#{ model }_child_id"] = new_child.id 
          end
        end
        
        nil
      end
      
      # Like has_many :projects
      #
      def child_documents(model, opts = {})
        model = model.to_s.downcase
        
        begin
          child_class = eval(model.modulize)
        rescue
          require "#{ model.methodize }.rb"
          retry
        end
        
        # Add a view to the child class
        View.create!(child_class.design_doc, "#{ crumb_type }_parent_id", View.advanced_json(File.join(File.dirname(__FILE__), "templates", "children.json"), :parent => self.crumb_type, :child => model))
        
        # Add a method to access the model's new view
        self.class_eval do
          define_method(English::Inflect.plural(model)) do
            query(eval(model.modulize).views(:name => "#{ self.class.crumb_type }_parent_id").uri).collect do |row|
              child_class.get!(row["doc"]["_id"])
            end
          end
          
          define_method("add_#{ model }") do |new_child|
            new_child.send("#{ self.class.crumb_type }_parent_id=", self.id)
            new_child.save!
          end
        end
        
        nil
      end
      
    end
    
    # Mixin our document methods
    #
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.extend(ClassMethods)
      # Override #initialize
      base.class_eval do
        
        # Set class variables
        class_variable_set(:@@crumb_type, base.name.split('::').last.downcase)
        class_variable_set(:@@database, CouchCrumbs::default_database)
        class_variable_set(:@@properties, [])
        
        # Accessors
        attr_accessor :uri, :raw
        
        # Override document #initialize
        def initialize(opts = {})
          raise ArgumentError.new("opts must be hash-like: #{ opts }") unless opts.respond_to?(:[])

          # If :json is present, we just parse it as an existing document
          if opts[:json]
            self.raw = JSON.parse(opts[:json])
          elsif opts[:hash]
            self.raw = opts[:hash]
          else
            self.raw = {}
            
            # Init special values
            raw["_id"] = opts[:id] || database.server.uuids
            raw["_rev"] = opts[:rev] unless opts[:rev].eql?(nil)
            raw["crumb_type"] = self.class.crumb_type
            raw["created_at"] = Time.now if self.class.properties.include?(:created_at)
            
            # Init named properties
            opts.each_pair do |name, value|
              send("#{ name }=", value)
            end
          end
          
          # This specific CouchDB document URI
          self.uri = File.join(database.uri, id)
          
          # Callback
          after_initialize
        end
        
      end
      
      # Create an advanced "all" view
      View.create!(base.design_doc, "all", View.advanced_json(File.join(File.dirname(__FILE__), "templates", "all.json"), :crumb_type => base.crumb_type))
    end
    
  end
  
end
