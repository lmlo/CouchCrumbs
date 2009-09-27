$:.unshift(File.dirname(__FILE__))

require "core_ext/array.rb"

require "couch_crumbs/couch_server.rb"

module CouchCrumbs

  # Connect to a specific couch server/database
  #
  # ==== Parameters
  # server<String>:: host/port in URI form
  # database<String>:: database name
  #
  def self.connect(opts = {})
    opts = {
      :server     => CouchServer::default_server_uri,
      :database   => CouchServer::default_database
    }.merge(opts)

    CouchServer.new(opts)
  end
  
  #===========================================================================
  
  module ClassMethods
    
  end
  
  module InstanceMethods
    
  end
  
  #===========================================================================
  
  # :nodoc:
  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
  end
    
end