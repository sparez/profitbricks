module Profitbricks
  class Server < Profitbricks::Model
    has_many :nics

    def delete
      response = Profitbricks.request :delete_server, "<serverId>#{self.id}</serverId>"
      return true if response.to_hash[:delete_server_response][:return]
    end

    def reboot
      response = Profitbricks.request :reboot_server, "<serverId>#{self.id}</serverId>"
      return true if response.to_hash[:reboot_server_response][:return]
    end

    def update(options = {})
      return false if options.empty?
      raise ArgumentError.new(":ram has to be at least 256MiB and a multiple of it") if options[:ram] < 256 or (options[:ram] % 256) > 0
      raise ArgumentError.new(":os_type has to be either 'WINDOWS' or 'OTHER'") if options[:os_type] and !['WINDOWS', 'OTHER'].include? options[:os_type]
      xml = "<arg0><serverId>#{self.id}</serverId>"
      if options[:cores]
        xml += "   <cores>#{options[:cores]}</cores>" 
        @cores = options[:cores]
      end
      if options[:ram]
        xml += "   <ram>#{options[:ram]}</ram>"
        @ram = options[:ram]
      end
      if options[:name]
        xml += "   <serverName>#{options[:name]}</serverName>"
        @name = options[:name]
      end
      if options[:boot_from_storage_id]
        xml += "   <bootFromStorageId>#{options[:boot_from_storage_id]}</bootFromStorageId>" 
        @boot_from_storage_id = options[:boot_from_storage_id]
      end
      if options[:boot_from_image_id]
        xml += "   <bootFromImageId>#{options[:boot_from_image_id]}</bootFromImageId>"
        @boot_from_image_id = options[:boot_from_image_id]
      end
      if options[:os_type]
        xml += "   <osType>#{options[:os_type]}</osType>"
        @os_type = options[:os_type]
      end
      xml += "</arg0>"
      response = Profitbricks.request :update_server, xml
    end

    class << self
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