module Profitbricks
  VERSION = '0.0.1'
  def self.client=(client)
    @client = client
  end
  def self.client 
    @client
  end
  def self.debug=(debug)
    @debug = debug
  end
  def self.debug 
    @debug
  end

  def self.request(method, body=nil)
    begin
      resp = Profitbricks.client.request method do
        soap.body = body if body
      end
      self.store(method, body, resp.to_xml, resp.to_hash) if self.debug
      resp
    rescue Savon::SOAP::Fault => fault
      raise fault
    end
  end

  def self.store(method, body, xml, json)
    require 'digest/sha1'
    hash = Digest::SHA1.hexdigest 'xml'

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