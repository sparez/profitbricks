module Profitbricks
  class DataCenter < Profitbricks::Model
    has_many :servers
    has_many :storages

    # Deletes an empty Virtual Data Center. All components must be removed first.
    # @return [Boolean] true on success, false otherwise
    def delete
      response = Profitbricks.request :delete_data_center, "<dataCenterId>#{self.id}</dataCenterId>"
      response.to_hash[:delete_data_center_response][:return] ? true : false
    end

    # Removes all components from the current Virtual Data Center.
    # @return The current Virtual Data Center
    def clear
      response = Profitbricks.request :clear_data_center, "<dataCenterId>#{self.id}</dataCenterId>"
      @provisioning_state = nil
      @servers = []
      @storages = []
      return self if response.to_hash[:clear_data_center_response][:return]
    end
    
    # Renames the Virtual Data Center. 
    #
    # @param [String] Name
    # @return [DataCenter] The renamed DataCenter
    def rename(name)
      response = Profitbricks.request :update_data_center,
                  "<arg0><dataCenterId>#{self.id}</dataCenterId><dataCenterName>#{name}</dataCenterName></arg0>"
      if response.to_hash[:update_data_center_response][:return]
        @name = name
      end
      self
    end
    alias_method :name=, :rename

    # This is a lightweight function for pooling the current provisioning state of the Virtual Data 
    # Center. It is recommended to use this function for large Virtual Data Centers to query request 
    # results.
    #
    # @return [String] Provisioning State of the target Virtual Data Center (INACTIVE, INPROCESS, AVAILABLE, DELETED)
    def update_state
      response = Profitbricks.request :get_data_center_state, "<dataCenterId>#{self.id}</dataCenterId>"
      @provisioning_state = response.to_hash[:get_data_center_state_response][:return]
      self.provisioning_state
    end

    # Creates a Server in the current Virtual Data Center, automatically sets the :data_center_id
    # @see Profitbricks::Server#create
    def create_server(options)
      Server.create(options.merge(:data_center_id => self.id))
    end

    def wait_for_provisioning
      self.update_state
      while @provisioning_state != 'AVAILABLE'
        self.update_state
        sleep 1
      end
      self.reload
    end

    class << self
      # Returns a list of all Virtual Data Centers created by the user, including ID, name and version number.
      # 
      # @return [Array <DataCenter>] Array of all available DataCenter
      def all
        resp = Profitbricks.request :get_all_data_centers
        datacenters = resp.to_hash[:get_all_data_centers_response][:return]
        [datacenters].flatten.compact.collect do |dc|
          PB::DataCenter.find(:id => PB::DataCenter.new(dc).id)
        end
      end
      
      # Creates and saves a new, empty Virtual Data Center.
      #
      # @param [String] Name of the Virtual Data Center (can not start with or contain (@, /, \\, |, ", '))
      # @return [DataCenter] The newly created Virtual Data Center
      def create(name)
        response = Profitbricks.request :create_data_center, "<dataCenterName>#{name}</dataCenterName>"
        self.find(:id => response.to_hash[:create_data_center_response][:return][:data_center_id] )
      end

      # Finds a Virtual Data Center
      # @param [Hash] options either name or id of the Virtual Data Center
      # @option options [String] :name The name of the Virtual Data Center
      # @option options [String] :id The id of the Virtual Data Center
      def find(options = {})
        if options[:name]
          dc = PB::DataCenter.all().select { |d| d.name == options[:name] }.first
          options[:id] = dc.id if dc
        end
        raise "Unable to locate the datacenter named '#{options[:name]}'" unless options[:id]
        response = Profitbricks.request :get_data_center, "<dataCenterId>#{options[:id]}</dataCenterId>"
        PB::DataCenter.new(response.to_hash[:get_data_center_response][:return])
      end
    end

  end
end
