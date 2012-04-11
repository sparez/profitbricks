module Profitbricks
  class Firewall < Profitbricks::Model
    has_many :rules, :class_name => :firewall_rule

    def initialize(hash, parent=nil)
      @parent = parent
      super(hash)
    end

    
    # Adds accept-rules to the firewall of a NIC or Load Balancer. 
    # 
    # If no firewall exists, a new inactive firewall is created. 
    #
    # @param [Array<FirewallRule>] Array of FirewallRules to add
    # @return [Boolean] true on success, false otherwise
    def add_rules(rules)
      xml = ""
      rules.each do |rule|
        xml += "<request>"
        xml += rule.get_xml_and_update_attributes rule.attributes, rule.attributes.keys
        xml += "</request>"
      end
      response = nil
      if @parent.class == Profitbricks::LoadBalancer
        xml += "<loadBalancerId>#{@parent.id}</loadBalancerId>"
        response = Profitbricks.request :add_firewall_rules_to_load_balancer, xml
        update_attributes(response.to_hash[:add_firewall_rules_to_load_balancer_response][:return])
        return true if response.to_hash[:add_firewall_rules_to_load_balancer_response][:return]
      else
        xml += "<nicId>#{self.nic_id}</nicId>"        
        response = Profitbricks.request :add_firewall_rules_to_nic, xml
        update_attributes(response.to_hash[:add_firewall_rules_to_nic_response][:return])
        return true if response.to_hash[:add_firewall_rules_to_nic_response][:return]
      end
      
    end

    # Activates the Firewall
    #
    # @return [Boolean] true on success, false otherwise
    def activate
      response = Profitbricks.request :activate_firewalls, "<firewallIds>#{self.id}</firewallIds>"
      return true if response[:activate_firewalls_response][:return]
    end

    # Deactivates the Firewall
    #
    # @return [Boolean] true on success, false otherwise
    def deactivate
      response = Profitbricks.request :deactivate_firewalls, "<firewallIds>#{self.id}</firewallIds>"
      return true if response[:deactivate_firewalls_response][:return]
    end
    
    # Deletes the Firewall
    #
    # @return [Boolean] true on success, false otherwise
    def delete
      response = Profitbricks.request :delete_firewalls, "<firewallIds>#{self.id}</firewallIds>"
      return true if response[:delete_firewalls_response][:return]
    end
    class << self
      # Returns information about the respective firewall. 
      # Each rule has an identifier for later modification.
      #
      # @param [Hash] options currently just :id is supported
      # @option options [String] :id The id of the firewall to locate (required)
      # @return [Firewall] The located Firewall
      def find(options = {})
        response = Profitbricks.request :get_firewall, "<firewallId>#{options[:id]}</firewallId>"
        # FIXME we cannot load the Firewall without knowing if it is belonging to a NIC or a LoadBalancer
        PB::Firewall.new(response.to_hash[:get_firewall_response][:return], nil)
      end
    end
  end
end