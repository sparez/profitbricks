module Profitbricks
  class Image < Profitbricks::Model

    # Sets the OS Type of an individual HDD and/or CD-ROM/DVD image that has been uploaded on the ProfitBricks FTP server.  
    # 
    # @param [String] OS Type of the target HDD or CD-ROM/DVD image (WINDOWS, OTHER)
    # @return [Image] Updated Image Object
    def set_os_type(type)
      raise ArgumentError.new(":os_type has to be either 'WINDOWS' or 'OTHER'") if !['WINDOWS', 'OTHER'].include? type
      response = Profitbricks.request :set_image_os_type, "<imageId>#{self.id}</imageId><osType>#{type}</osType>"
      @os_type = type
      self
    end
    alias_method :os_type=, :set_os_type

    class << self
      # Returns information about a HDD or CD-ROM/DVD (ISO) image. 
      #
      # @param [Hash] options either name or id of the Image
      # @option options [String] :name The name of the Image
      # @option options [String] :id The id of the Image
      # @return [Image] The found Image Object 
      def find(options = {})
        image = nil
        if options[:name]
          image = PB::Image.all().select { |d| d.name == options[:name] }.first
          options[:id] = image.id if image
        end
        raise "Unable to locate the image named '#{options[:name]}'" unless options[:id]
        image
        # This does not work for public images
        #response = Profitbricks.request :get_image, "<imageId>#{options[:id]}</imageId>"
        #PB::Image.new(response.to_hash[:get_image_response][:return])
      end
      
      # Outputs a list of all HDD and/or CD-ROM/DVD images existing on or uploaded to the Profit-Bricks FTP server. 
      #
      # @return [Array<Image>] List of all available Images
      def all
        resp = Profitbricks.request :get_all_images
        resp.to_hash[:get_all_images_response][:return].collect do |dc|
          PB::Image.new(dc)
        end
      end
    end
  end
end