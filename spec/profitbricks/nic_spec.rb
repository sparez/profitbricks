require 'spec_helper'

describe Profitbricks::Nic do
  include Savon::Spec::Macros

  it "create a new Nic" do
    savon.expects(:create_nic).returns(:success)
    savon.expects(:get_nic).returns(:success)
    nic = Nic.create(:lan_id => 1, :ip => "192.168.0.11", :name => "Internal", :server_id => "4cb6550f-3777-4818-8f4c-51233162a980")
    nic.name.should == "Internal"
    nic.lan_id.should == 1
    nic.ip.should == "192.168.0.11"
  end

  it "should update an existing Nic" do
    savon.expects(:get_nic).returns(:success)
    savon.expects(:update_nic).returns(:success)
    nic = Nic.find(:id => "cba8af39-b5de-477b-9795-2f02ea9cf04f")
    nic.update(:name => "External").should == true
    nic.name.should == "External"
  end

  it "should set the internet access" do
    savon.expects(:get_nic).returns(:success)
    savon.expects(:set_internet_access).returns(:success)
    nic = Nic.find(:id => "cba8af39-b5de-477b-9795-2f02ea9cf04f")
    (nic.set_internet_access = true).should == true
  end

  it "should be deleted" do
    savon.expects(:get_nic).returns(:success)
    savon.expects(:delete_nic).returns(:success)
    nic = Nic.find(:id => "cba8af39-b5de-477b-9795-2f02ea9cf04f")
    nic.delete.should == true
  end

  it "should add an ip" do
    savon.expects(:get_nic).returns(:success)
    savon.expects(:add_public_ip_to_nic).returns(:success)
    nic = Nic.find(:id => "cba8af39-b5de-477b-9795-2f02ea9cf04f")
    nic.add_ip("46.16.74.13")
    nic.ips.count.should == 2
    lambda {
      nic.ip
    }.should raise_error ArgumentError
  end
  
  it "should remove an ip" do
    savon.expects(:get_nic).returns(:success)
    savon.expects(:remove_public_ip_from_nic).returns(:success)
    nic = Nic.find(:id => "cba8af39-b5de-477b-9795-2f02ea9cf04f")
    nic.remove_ip("46.16.74.13")
    nic.ips.count.should == 1
  end
end