module Profitbricks
  class DataCenter < Profitbricks::Model
    has_many :servers

    def delete
      response = Profitbricks.request :delete_data_center, "<dataCenterId>#{self.id}</dataCenterId>"
      return true if response.to_hash[:delete_data_center_response][:return]
    end

    def clear
      response = Profitbricks.request :clear_data_center, "<dataCenterId>#{self.id}</dataCenterId>"
      @provisioning_state = nil
      @servers = []
      @storages = []
      return self if response.to_hash[:clear_data_center_response][:return]
    end

    def rename(name)
      response = Profitbricks.request :update_data_center,
                  "<arg0><dataCenterId>#{self.id}</dataCenterId><dataCenterName>#{name}</dataCenterName></arg0>"
      if response.to_hash[:update_data_center_response][:return]
        @name = name
      end
      self
    end

    def name=(name)
      self.rename(name)
    end

    def update_state
      response = Profitbricks.request :get_data_center_state, "<dataCenterId>#{self.id}</dataCenterId>"
      @provisioning_state = response.to_hash[:get_data_center_state_response][:return]
      self.provisioning_state
    end

    def create_server(options)
      s = Server.create(options.merge(:data_center_id => self.id))
      @servers << s
      s
    end

    class << self
      def all
        resp = Profitbricks.request :get_all_data_centers
        datacenters = resp.to_hash[:get_all_data_centers_response][:return]
        [datacenters].flatten.collect do |dc|
          PB::DataCenter.new(dc)
        end
      end

      def create(name)
        response = Profitbricks.request :create_data_center, "<dataCenterName>#{name}</dataCenterName>"
        PB::DataCenter.new(response.to_hash[:create_data_center_response][:return].merge(:data_center_name => name))
      end

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
