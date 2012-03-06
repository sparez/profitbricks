module Profitbricks
  class Config
    class << self
      # Your Profitbricks username (required)
      attr_accessor :username 
      # Your Profitbricks password (required)
      attr_accessor :password
      # Disable namespacing the classes, set to false to avoid name conflicts, default: true
      attr_accessor :global_classes
      # Development only, saves SOAP responses on disk, default: false
      attr_accessor :save_responses
      # Set to true to enable Savons request/response logging, default: false
      attr_accessor :log
    end
  end
end