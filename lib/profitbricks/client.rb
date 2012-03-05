module Profitbricks
  @client = nil
  class Client
    def initialize(username, password, &block)
      @username = username
      @password = password
      Savon.configure do |config|
        config.raise_errors = false 
      end
      @client = Savon::Client.new do |wsdl, http|
        wsdl.endpoint = "https://api.profitbricks.com/1.1"
        wsdl.document = "https://api.profitbricks.com/1.1/wsdl"
        http.auth.basic @username, @password
      end
      @cache = {}
      Profitbricks.client = @client
      Profitbricks.constants.select {|c| Class === Profitbricks.const_get(c)}.each do |klass|
        next if klass == :Client
        unless Kernel.const_defined?(klass)
          Kernel.const_set(klass, Profitbricks.const_get(klass))
        end
      end

      yield self if block
    end
  end

end