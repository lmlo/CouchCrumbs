require "validatable"

module CouchCrumbs
  
  # Document is an abstract base module that you mixin to your own classes.
  #
  module Document
    
    def self.included(base)
      base.extend(ClassMethods)
      base.class_eval do
        
        attr_accessor :database, :uri, :raw
        attr_writer :type

        def initialize(opts = {})
          raise ArgumentError.new("opts must be hash-like: #{ opts }") unless opts.respond_to?(:[])
                    
          # Per document databases (optional)
          self.database = opts[:database] || CouchCrumbs::default_database
          
          # If :json is present, we just parse an existing document
          if opts[:json]
            self.raw = JSON.parse(opts[:json])
          else
            self.raw = {}
            
            self.raw["_id"] = opts[:id] || database.server.uuids
            self.raw["_rev"] = opts[:rev] unless opts[:rev].eql?(nil)
            # New documents need to have a 'type' set
            self.raw["type"] = self.type = self.class.name.split('::').last

            # @todo - turn all opts keys into symbols
            
            # Property inits
            self.class.properties.each do |name|
              self.raw[name.to_s] = opts[name]
            end
          end
          
          self.uri = File.join(database.uri, id)
        end

      end
      base.send(:include, InstanceMethods)
    end
    
    # Return a specific document given an id
    #
    def self.get!(id)
      json = RestClient.get(File.join(CouchCrumbs::default_database.uri, id))
      
      result = JSON.parse(json)
      
      document = eval(result["type"]).new(
        :json => json
      )

      document
    end
    
    #include Validatable
    
    module ClassMethods
      
      # Return a specific document given an id
      #
      def get!(id)
        json = RestClient.get(File.join(CouchCrumbs::default_database.uri, id))

        result = JSON.parse(json)

        document = new(
          :json => json
        )

        document
      end

      # Create and save a new document
      # @todo - add before_create and after_create callbacks
      def create(opts = {})
        document = new(opts)

        yield document if block_given?

        document.save

        document
      end

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
      
      def properties
        @@properties ||= []
      end
      
      def view_by(name, opts = {})

      end

      def has_many(models, opts = {})

      end

      def belongs_to(model, opts = {})

      end

      def timestamps!

      end

      def save_callback(point, opts = {})

      end

      def validates_with_method(method_name)

      end
      
    end
    
    module InstanceMethods
      
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

        result = JSON.parse(RestClient.put(uri, self.raw.to_json))

        self.raw["_id"] = result["id"]
        self.raw["_rev"] = result["rev"]

        result["ok"]
      end
    
      # Return true prior to document being saved
      #
      def new_document?
        raw["_rev"].eql?(nil)
      end
      
      # Remove document from the database
      #
      def destroy!
        freeze
        
        # Since new documents haven't been saved yet, simply return true
        if new_document?
          true
        else
          result = JSON.parse(RestClient.delete(File.join(uri, "?rev=#{ self.rev }")))
          result["ok"]
        end
      end
      
    end
    
  end
  
end
