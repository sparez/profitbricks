module Profitbricks
  class Storage < Profitbricks::Model

    def delete
      response = Profitbricks.request :delete_stoarge, "<stoargeId>#{self.id}</stoargeId>"
      return true if response.to_hash[:delete_stoarge_response][:return]
    end

    class << self
      def create(options = {})
        raise ArgumentError.new("You must provide a :data_center_id") if options[:data_center_id].nil?
        xml = "<arg0>"
        xml += get_xml_and_update_attributes options, [:data_center_id, :name, :size, :mount_image_id]
        xml += "</arg0>"
        response = Profitbricks.request :create_storage, xml
        self.find(:id => response.to_hash[:create_storage_return][:return][:storage_id])
      end

      def find(options = {})
        raise "Unable to locate the storage named '#{options[:name]}'" unless options[:id]
        response = Profitbricks.request :get_storage, "<storageId>#{options[:id]}</storageId>"
        Profitbricks::Storage.new(response.to_hash[:get_image_response][:return])
      end

      def all
        resp = Profitbricks.request :get_all_images
        puts resp.to_xml
        resp.to_hash[:get_all_images_response][:return].collect do |dc|
          Profitbricks::Storage.new(dc)
        end
      end
    end
  end
end