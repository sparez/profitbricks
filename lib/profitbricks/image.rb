module Profitbricks
  class Image < Profitbricks::Model

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