module Profitbricks
  VERSION = '0.0.1'


  # Configure the Profitbricks API client
  #
  # @see Profitbricks::Config
  def self.configure(&block)
    Profitbricks::Config.save_responses = false
    Profitbricks::Config.log = false
    Profitbricks::Config.global_classes = true
    yield Profitbricks::Config

    Savon.configure do |config|
      config.raise_errors = false 
      config.log = Profitbricks::Config.log
    end
    HTTPI.log = false

    @client = Savon::Client.new do |wsdl, http|
      wsdl.endpoint = "https://api.profitbricks.com/1.1"
      wsdl.document = "https://api.profitbricks.com/1.1/wsdl"
      http.auth.basic Profitbricks::Config.username, Profitbricks::Config.password
    end

    Profitbricks.client = @client
    if Profitbricks::Config.global_classes
      Profitbricks.constants.select {|c| Class === Profitbricks.const_get(c)}.each do |klass|
        next if klass == :Config
        unless Kernel.const_defined?(klass)
          Kernel.const_set(klass, Profitbricks.const_get(klass))
        end
      end
    end
  end

  private 
  def self.request(method, body=nil)
    resp = Profitbricks.client.request method do
      soap.body = body if body
    end
    self.store(method, body, resp.to_xml, resp.to_hash) if Profitbricks::Config.save_responses
    if resp.soap_fault?
      puts "Error during request '#{method}': #{resp.soap_fault.message}"
      puts "------------------------------ Request XML -------------------------------"
      puts body
      puts "--------------------------------------------------------------------------"
      puts "------------------------------ Response XML ------------------------------"
      puts resp.to_xml
      puts "--------------------------------------------------------------------------"
      raise RuntimeError.new("Error during request '#{method}': #{resp.soap_fault.message}")
    end
    resp
  end

  def self.client=(client)
    @client = client
  end

  def self.client
    @client
  end

  def self.store(method, body, xml, json)
    require 'digest/sha1'
    hash = Digest::SHA1.hexdigest xml

    unless Dir.exists?(File.expand_path("../../../spec/fixtures/#{method}", __FILE__))
      Dir.mkdir(File.expand_path("../../../spec/fixtures/#{method}", __FILE__))
    end
    File.open(File.expand_path("../../../spec/fixtures/#{method}/#{hash}.xml", __FILE__), 'w').write(xml)
    File.open(File.expand_path("../../../spec/fixtures/#{method}/#{hash}.json", __FILE__), 'w').write(JSON.dump(json))
  end

  def self.get_class name
    klass = name
    if Profitbricks.const_defined?(klass)
      klass = Profitbricks.const_get(klass)
    else
      begin
        require "profitbricks/#{name.downcase}"
        klass = Profitbricks.const_get(klass)
      rescue LoadError
        raise LoadError.new("Invalid association, could not locate the class '#{name}'")
      end
    end
    klass
  end
end  