require 'spec_helper'

describe Profitbricks::Server do
  include Savon::Spec::Macros

  it "should create a new server with minimal arguments" do
    savon.expects(:create_server).returns(:minimal)
    savon.expects(:get_server).returns(:after_create)
    s = Server.create(:cores => 1, :ram => 256, :name => 'Test Server', :data_center_id => "b3eebede-5c78-417c-b1bc-ff5de01a0602")
    s.cores.should == 1
    s.ram.should == 256
    s.name.should == 'Test Server'
    s.data_center_id.should == "b3eebede-5c78-417c-b1bc-ff5de01a0602"
  end
  it "should reboot on request" do
    savon.expects(:get_server).returns(:after_create)
    savon.expects(:reboot_server).returns(:success)
    s = Server.find(:id => "b3eebede-5c78-417c-b1bc-ff5de01a0602")
    s.reboot.should == true
  end

  it "should be deleted" do
    savon.expects(:get_server).returns(:after_create)
    savon.expects(:delete_server).returns(:success)
    s = Server.find(:id => "b3eebede-5c78-417c-b1bc-ff5de01a0602")
    s.delete.should == true
  end

  describe "updating" do
    it "should update basic attributes correctly" do 
      savon.expects(:get_server).returns(:after_create)
      savon.expects(:update_server).returns(:basic)
      s = Server.find(:id => "b3eebede-5c78-417c-b1bc-ff5de01a0602")
      s.update(:cores => 2, :ram => 512, :name => "Power of two", :os_type => 'WINDOWS')
      s.cores.should == 2
      s.ram.should == 512
      s.name.should == "Power of two"
      s.os_type.should == 'WINDOWS'
    end
  end
end