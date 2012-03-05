module Profitbricks
  class Storage < Profitbricks::Model

    # Deletes an existing virtual storage device.
    #
    # @return [Boolean] true on success, false otherwise
    def delete
      response = Profitbricks.request :delete_storage, "<storageId>#{self.id}</storageId>"
      return true if response.to_hash[:delete_storage_response][:return]
    end

    # Connects a virtual storage device to an existing server.
    #
    # @param [Hash] options Parameters to connect the Storage
    # @option options [:server_id] Identifier of the target virtual server (required) 
    # @option options [:bus_type] Bus type to which the storage will be connected. Type can be IDE, SCSI or VIRTIO (required)
    # @option options [:device_number] Defines the device number of the virtual storage. If no device number is set, a device number will be automatically assigned 
    # @return [Boolean] true on success, false otherwise
    def connect(options = {})
      xml = "<arg0>"
      xml += get_xml_and_update_attributes options.merge(:storage_id => self.id), [:server_id, :storage_id, :bus_type, :device_number]
      xml += "</arg0>"
      response = Profitbricks.request :connect_storage_to_server, xml
      return true if response.to_hash[:connect_storage_to_server_response][:return]
    end

    # Disconnects a virtual storage device from a connected server.
    #
    # @param [Hash] options Parameters to disconnect the Storage
    # @option options [:server_id] Identifier of the connected virtual server (required) 
    # @return [Boolean] true on success, false otherwise
    def disconnect(options = {})
      response = Profitbricks.request :disconnect_storage_from_server, 
                      "<storageId>#{self.id}</storageId><serverId>#{options[:server_id]}</serverId>"
      return true if response.to_hash[:disconnect_storage_from_server_response][:return]
    end

    # Updates parameters of an existing virtual storage device. 
    #
    # @param [Hash] options Parameters to update the Storage
    # @option options [:size] Storage size (in GiB)
    # @option options [:name] Name of the storage to be created
    # @option options [:mount_image_id] Specifies the image to be assigned to the storage by its ID. Either choose a HDD or a CD-ROM/DVD (ISO) image
    # @return [Boolean] true on success, false otherwise
    def update(options = {})
      xml = "<arg0>"
      xml += get_xml_and_update_attributes options.merge(:storage_id => self.id), [:storage_id, :name, :size, :mount_image_id]
      xml += "</arg0>"
      response = Profitbricks.request :update_storage, xml
      return true if response.to_hash[:update_storage_response][:return]
    end

    class << self
      # Creates a virtual storage within an existing virtual data center. Additional parameters can be 
      # specified, e.g. for assigning a HDD image to the storage.
      #
      # @param [Hash] options Parameters for the new Storage
      # @option options [:size] Storage size (in GiB) (required)
      # @option options [:data_center_id] Defines the data center wherein the storage is to be created. If left empty, the storage will be created in a new data center
      # @option options [:name] Name of the storage to be created
      # @option options [:mount_image_id] Specifies the image to be assigned to the storage by its ID. Either choose a HDD or a CD-ROM/DVD (ISO) image
      # @return [Storage] The created Storage
      def create(options = {})
        raise ArgumentError.new("You must provide a :data_center_id") if options[:data_center_id].nil?
        xml = "<arg0>"
        xml += get_xml_and_update_attributes options, [:data_center_id, :name, :size, :mount_image_id]
        xml += "</arg0>"
        response = Profitbricks.request :create_storage, xml
        self.find(:id => response.to_hash[:create_storage_return][:return][:storage_id])
      end

      # Finds a storage device
      #
      # @param [Hash] options currently just :id is supported
      # @option options [String] The id of the storage to locate
      # @return [Storage]
      def find(options = {})
        raise "Unable to locate the storage named '#{options[:name]}'" unless options[:id]
        response = Profitbricks.request :get_storage, "<storageId>#{options[:id]}</storageId>"
        Profitbricks::Storage.new(response.to_hash[:get_storage_response][:return])
      end
    end
  end
end