require 'spec_helper'

describe Profitbricks::LoadBalancer do
  include Savon::Spec::Macros
  let(:servers) { [Server.new(:id => "206d10f2-035f-4ef2-8d24-3022653e9706")]}

  it "create a new LoadBalancer" do
    savon.expects(:create_load_balancer).returns(:success)
    savon.expects(:get_load_balancer).returns(:success)
    lb = LoadBalancer.create(:data_center_id => "1111", :name => "Test", :servers => servers, :algorithm => 'ROUND_ROBIN')
    lb.name.should == "Test"
    lb.lan_id.should == 0
    lb.algorithm.should == "ROUND_ROBIN"
  end

  it "should update an existing LoadBalancer" do
    savon.expects(:get_load_balancer).returns(:success)
    savon.expects(:update_load_balancer).returns(:success)
    savon.expects(:get_load_balancer).returns(:success)
    lb = LoadBalancer.find(:id => "5dadd2b2-3405-4ec5-a450-0df497bebab0")
    lb.update(:name => "Wee").should == true
    # FIXME seems to be a bug in the API
    lb.name.should == "Test"
  end

  it "should be deleted" do
    savon.expects(:get_load_balancer).returns(:success)
    savon.expects(:delete_load_balancer).returns(:success)
    lb = LoadBalancer.find(:id => "5dadd2b2-3405-4ec5-a450-0df497bebab0")
    lb.delete.should == true
  end

  it "should register a server" do
    savon.expects(:get_load_balancer).returns(:success)
    savon.expects(:register_servers_on_load_balancer).returns(:success)
    lb = LoadBalancer.find(:id => "5dadd2b2-3405-4ec5-a450-0df497bebab0")
    lb.register_servers(servers).should == true
  end
  
  it "should deregister a server" do
    savon.expects(:get_load_balancer).returns(:success)
    savon.expects(:deregister_servers_on_load_balancer).returns(:success)
    lb = LoadBalancer.find(:id => "5dadd2b2-3405-4ec5-a450-0df497bebab0")
    lb.deregister_servers(servers).should == true
  end

  it "should activate a server" do
    savon.expects(:get_load_balancer).returns(:success)
    savon.expects(:activate_load_balancing_on_servers).returns(:success)
    lb = LoadBalancer.find(:id => "5dadd2b2-3405-4ec5-a450-0df497bebab0")
    lb.activate_servers(servers).should == true
  end

  it "should deactivate a server" do
    savon.expects(:get_load_balancer).returns(:success)
    savon.expects(:deactivate_load_balancing_on_servers).returns(:success)
    lb = LoadBalancer.find(:id => "5dadd2b2-3405-4ec5-a450-0df497bebab0")
    lb.deactivate_servers(servers).should == true
  end
end