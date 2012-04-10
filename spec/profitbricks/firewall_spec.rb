require 'spec_helper'
require 'json'

describe Profitbricks::Firewall do
  include Savon::Spec::Macros
  let(:dc) { DataCenter.new(JSON.parse(File.open('spec/fixtures/get_data_center/firewall.json').read)["get_data_center_response"]["return"])}

  it "should add new rules to a firewall of a load balancer" do
    savon.expects(:add_firewall_rules_to_load_balancer).returns(:success)
    fw = dc.load_balancers.first.firewall
    rule = FirewallRule.new(:port_range_start => 80, :port_range_end => 80, :protocol => 'TCP')
    fw.add_rules([rule]).should == true
  end

  it "should add new rules to a firewall of a nic" do
    savon.expects(:add_firewall_rules_to_nic).returns(:success)
    fw = dc.servers.first.nics.first.firewall
    rule = FirewallRule.new(:port_range_start => 80, :port_range_end => 80, :protocol => 'TCP')
    fw.add_rules([rule]).should == true
  end
  
  it "should activate a firewall" do
    savon.expects(:get_firewall).returns(:success)
    savon.expects(:activate_firewalls).returns(:success)
    fw = Firewall.find(:id => "33f4e0a5-41d9-eb57-81d1-24854ed89834")
    fw.activate.should == true
  end

  it "should deactivate a firewall" do
    savon.expects(:get_firewall).returns(:success)
    savon.expects(:deactivate_firewalls).returns(:success)
    fw = Firewall.find(:id => "33f4e0a5-41d9-eb57-81d1-24854ed89834")
    fw.deactivate.should == true
  end

  it "should delete a firewall" do
    savon.expects(:get_firewall).returns(:success)
    savon.expects(:delete_firewalls).returns(:success)
    fw = Firewall.find(:id => "33f4e0a5-41d9-eb57-81d1-24854ed89834")
    fw.delete.should == true
  end

  it "should delete a firewall rule" do
    savon.expects(:get_firewall).returns(:success)
    savon.expects(:remove_firewall_rules).returns(:success)
    fw = Firewall.find(:id => "33f4e0a5-41d9-eb57-81d1-24854ed89834")
    fw.rules.first.delete.should == true
  end
end