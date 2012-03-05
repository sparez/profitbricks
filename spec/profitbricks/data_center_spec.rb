require 'spec_helper'

describe Profitbricks::DataCenter do
  include Savon::Spec::Macros

  let(:client) do
    Savon.configure do |config|
      config.log = false 
    end
    Savon::Client.new do
        wsdl.endpoint = "https://api.profitbricks.com/1.1"
        wsdl.document = "https://api.profitbricks.com/1.1/wsdl"
    end
  end

  before do
    Profitbricks::Client.new("nouser", "nopass") 
    Profitbricks.client = client
  end

  it "should create a new datacenter" do
    savon.expects(:create_data_center).returns(:success)
    dc = DataCenter.create('Test2')
    dc.name.should == 'Test2'
    dc.id.should == "a897fbd7-9f24-4eed-bd56-cadae6117755"
    dc.version.should == 1
  end

  it "should get a list of all datacenters" do
    savon.expects(:get_all_data_centers).returns(:test_datacenter)
    Profitbricks::DataCenter.all().count.should == 1
  end

  it "should find a datacenter with a given name" do
    savon.expects(:get_all_data_centers).returns(:test_datacenter)
    savon.expects(:get_data_center).returns(:two_servers_with_storage)
    dc = Profitbricks::DataCenter.find(:name => 'Test')
    dc.name.should == "Test"
    dc.id.should == "b3eebede-5c78-417c-b1bc-ff5de01a0602"
    dc.provisioning_state.should == "INPROCESS"
    dc.version.should == 9

    dc.servers.count.should == 2
    dc.servers.first.class.should == Server
  end

  it "should update its provisioning_state" do
    savon.expects(:get_data_center).returns(:two_servers_with_storage)
    savon.expects(:get_data_center_state).returns(:success)
    dc = Profitbricks::DataCenter.find(:id => "b3eebede-5c78-417c-b1bc-ff5de01a0602")
    dc.update_state().should == 'AVAILABLE'
    dc.provisioning_state.should == 'AVAILABLE'
  end
  
  it "should rename a datacenter" do
    savon.expects(:get_data_center).returns(:two_servers_with_storage)
    savon.expects(:update_data_center).returns(:success)
    dc = Profitbricks::DataCenter.find(:id => "b3eebede-5c78-417c-b1bc-ff5de01a0602")
    dc.rename("Test2")
    dc.name.should == 'Test2'
  end

  it "should rename a datacenter via setter" do
    savon.expects(:get_data_center).returns(:two_servers_with_storage)
    savon.expects(:update_data_center).returns(:success)
    dc = Profitbricks::DataCenter.find(:id => "b3eebede-5c78-417c-b1bc-ff5de01a0602")
    dc.name = "Test2"
    dc.name.should == 'Test2'
  end

  it "should clear the datacenter" do
    savon.expects(:get_data_center).returns(:two_servers_with_storage)
    savon.expects(:clear_data_center).returns(:success)
    dc = Profitbricks::DataCenter.find(:id => "b3eebede-5c78-417c-b1bc-ff5de01a0602")
    dc.clear
    dc.servers.count.should == 0
  end

  it "should delete a datacenter" do
    savon.expects(:get_data_center).returns(:two_servers_with_storage)
    savon.expects(:delete_data_center).returns(:success)
    dc = Profitbricks::DataCenter.find(:id => "b3eebede-5c78-417c-b1bc-ff5de01a0602")
    dc.delete.should == true
  end
end