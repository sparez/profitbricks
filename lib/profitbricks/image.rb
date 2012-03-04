module Profitbricks
  class Image
    attr_reader :cpu_hotpluggable, :id, :name, :size, :type, :memory_hotpluggable, :os, :writeable, :servers
    def initialize(hash)
      @cpu_hotpluggable    = hash[:cpu_hotpluggable]
      @id                  = hash[:image_id]
      @name                = hash[:image_name]
      @size                = hash[:image_size]
      @type                = hash[:image_type]
      @memory_hotpluggable = hash[:memory_hotpluggable]
      @os                  = hash[:os_type]
      @writeable           = hash[:writeable]
      @servers             = hash[:server_ids]
    end

    def update
      self.attributes = Image.find(self.id).attributes
    end

    class << self
      def find(options = {})
        if options[:name]
          dc = PB::Image.all().select { |d| d.name == options[:name] }.first
          options[:id] = dc.id if dc
        end
        raise "Unable to locate the image named '#{options[:name]}'" unless options[:id]
        response = Profitbricks.request :get_image, "<imageId>#{options[:id]}</imageId>"
        PB::Image.new(response.to_hash[:get_image_response][:return])
      end

      def all
        resp = Profitbricks.request :get_all_images
        puts resp.to_xml
        resp.to_hash[:get_all_images_response][:return].collect do |dc|
          PB::Image.new(dc)
        end
      end
    end
  end
end