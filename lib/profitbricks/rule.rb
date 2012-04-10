module Profitbricks
  class FirewallRule < Profitbricks::Model
    # Deletes the FirewallRule
    #
    # @return [Boolean] true on success, false otherwise
    def delete
      response = Profitbricks.request :remove_firewall_rules, "<firewallRuleIds>#{self.id}</firewallRuleIds>"
      return true if response[:remove_firewall_rules_response][:return]
    end
  end
end