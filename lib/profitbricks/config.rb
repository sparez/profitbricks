module Profitbricks
  class Config
    class << self
      attr_accessor :store_requests, :log, :username, :password, :global_classes
    end
  end
end