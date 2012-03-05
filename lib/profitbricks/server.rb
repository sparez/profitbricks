module Profitbricks
  class Server < Profitbricks::Model
    has_many :nics

    # Deletes the virtual Server. 
    # @return [Boolean] true on success, false otherwise
    def delete
      response = Profitbricks.request :delete_server, "<serverId>#{self.id}</serverId>"
      return true if response.to_hash[:delete_server_response][:return]
    end
    
    # Reboots the virtual Server (POWER CYCLE). 
    # @return [Boolean] true on success, false otherwise
    def reboot
      response = Profitbricks.request :reboot_server, "<serverId>#{self.id}</serverId>"
      return true if response.to_hash[:reboot_server_response][:return]
    end

    # Updates parameters of an existing virtual Server device. 
    # @param [Hash] options parameters for the new server
    # @option options [Fixnum] :cores Number of cores to be assigned to the specified server (required)
    # @option options [Fixnum] :ram Number of RAM memory (in MiB) to be assigned to the server. Must be at least 256 and a multiple of it. (required)
    # @option options [String]  :name Name of the server to be created
    # @option options [String]  :boot_from_image_id Defines an existing CD-ROM/DVD image ID to be set as boot device of the server. A virtual CD-ROM/DVD drive with the mounted image will be connected to the server.
    # @option options [String]  :boot_from_image_id Defines an existing storage device ID to be set as boot device of the server. The storage will be connected to the server implicitly.
    # @option options [String]  :os_type Sets the OS type of the server. (wInDows, other) If left empty, the server will inherit the OS Type of its selected boot image / storage.
    # @return [Boolean] true on success, false otherwise
    def update(options = {})
      return false if options.empty?
      raise ArgumentError.new(":ram has to be at least 256MiB and a multiple of it") if options[:ram] < 256 or (options[:ram] % 256) > 0
      raise ArgumentError.new(":os_type has to be either 'WINDOWS' or 'OTHER'") if options[:os_type] and !['WINDOWS', 'OTHER'].include? options[:os_type]
      xml = "<arg0><serverId>#{self.id}</serverId>"
      xml += get_xml_and_update_attributes options, [:cores, :ram, :name, :boot_from_storage_id, :boot_from_image_id, :os_type]
      xml += "</arg0>"
      pp xml
      response = Profitbricks.request :update_server, xml
      return true if response.to_hash[:update_server_response][:return]
    end

    class << self
      # Creates a Virtual Server within an existing data center. Parameters can be specified to set up a 
      # boot device and connect the server to an existing LAN or the Internet.
      # 
      # @param [Hash] options parameters for the new server
      # @option options [Fixnum] :cores Number of cores to be assigned to the specified server (required)
      # @option options [Fixnum] :ram Number of RAM memory (in MiB) to be assigned to the server. Must be at least 256 and a multiple of it. (required)
      # @option options [String]  :name Name of the server to be created
      # @option options [String]  :data_center_id Defines the data center wherein the server is to be created. If left empty, the server will be created in a new data center.
      # @option options [String]  :boot_from_image_id Defines an existing CD-ROM/DVD image ID to be set as boot device of the server. A virtual CD-ROM/DVD drive with the mounted image will be connected to the server.
      # @option options [String]  :boot_from_image_id Defines an existing storage device ID to be set as boot device of the server. The storage will be connected to the server implicitly.
      # @option options [Fixnum] :lan_id Connects the server to the specified LAN ID > 0. If the respective LAN does not exist, it is going to be created.
      # @option options [Boolean] :internet_access Set to true to connect the server to the internet via the specified LAN ID. If the LAN is not specified, it is going to be created in the next available LAN ID, starting with LAN ID 1
      # @option options [String]  :os_type Sets the OS type of the server. (wInDows, other) If left empty, the server will inherit the OS Type of its selected boot image / storage.
      # @return [Server] The created virtual server
      def create(options = {})
        raise ArgumentError.new("You must provide :cores and :ram") if options[:ram].nil? and options[:cores].nil?
        raise ArgumentError.new(":ram has to be at least 256MiB and a multiple of it") if options[:ram] < 256 or (options[:ram] % 256) > 0
        raise ArgumentError.new(":os_type has to be either 'WINDOWS' or 'OTHER'") if options[:os_type] and !['WINDOWS', 'OTHER'].include? options[:os_type]
        xml = "<arg0>"
        xml += "   <cores>#{options[:cores]}</cores>" 
        xml += "   <ram>#{options[:ram]}</ram>"
        xml += "   <serverName>#{options[:name]}</serverName>" if options[:name]
        xml += "   <dataCenterId>#{options[:data_center_id]}</dataCenterId>" if options[:data_center_id]
        xml += "   <bootFromStorageId>#{options[:boot_from_storage_id]}</bootFromStorageId>" if options[:boot_from_storage_id]
        xml += "   <bootFromImageId>#{options[:boot_from_image_id]}</bootFromImageId>" if options[:boot_from_image_id]
        xml += "   <internetAccess>#{options[:internet_access]}</internetAccess>" if options[:internet_access]
        xml += "   <lanId>#{options[:lan_id]}</lanId>" if options[:lan_id]
        xml += "   <osType>#{options[:os_type]}</osType>" if options[:os_type]
        xml += "</arg0>"
        response = Profitbricks.request :create_server, xml
        self.find(:id => response.to_hash[:create_server_return][:return][:server_id])
      end

      # Finds a virtual server
      #
      # @param [Hash] options currently just :id is supported
      # @option options [String] The id of the server to locate
      def find(options = {})
        # FIXME
        #if options[:name]
        #  dc = PB::Server.all().select { |d| d.name == options[:name] }.first
        #  options[:id] = dc.id if dc
        #end
        raise "Unable to locate the server named '#{options[:name]}'" unless options[:id]
        response = Profitbricks.request :get_server, "<serverId>#{options[:id]}</serverId>"
        PB::Server.new(response.to_hash[:get_server_response][:return])
      end
    end
  end
end