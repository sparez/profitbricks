require 'spec_helper'

describe Profitbricks::Storage do
  include Savon::Spec::Macros

  it "should create a new server with minimal arguments" do
    savon.expects(:create_storage).with("<arg0><dataCenterId>b3eebede-5c78-417c-b1bc-ff5de01a0602</dataCenterId><size>5</size><storageName>Test Storage</storageName></arg0>").returns(:success)
    savon.expects(:get_storage).with('<storageId>f55952bc-da27-4e29-af89-ed212ea28e11</storageId>').returns(:success)
    storage = Storage.create(:size => 5, :name => "Test Storage", :data_center_id => "b3eebede-5c78-417c-b1bc-ff5de01a0602")
    storage.name.should == "Test Storage"
    storage.size.should == 5
  end

  it "should be connectable to a server" do
    savon.expects(:get_storage).returns(:success)
    savon.expects(:connect_storage_to_server).returns(:success)
    savon.expects(:get_server).returns(:connected_storage)
    storage = Storage.find(:id => "f55952bc-da27-4e29-af89-ed212ea28e11")
    storage.connect(:server_id => "4cb6550f-3777-4818-8f4c-51233162a980", :bus_type => "VIRTIO").should == true
    s = Server.find(:id => "4cb6550f-3777-4818-8f4c-51233162a980")
    # FIXME
    s.connected_storages[:storage_name].should == "Test Storage"
  end

  it "should be disconnectable from a server" do
    savon.expects(:get_storage).returns(:success)
    savon.expects(:disconnect_storage_from_server).returns(:success)
    storage = Storage.find(:id => "f55952bc-da27-4e29-af89-ed212ea28e11")
    storage.disconnect(:server_id => "4cb6550f-3777-4818-8f4c-51233162a980").should == true
  end
  
  it "should be updated" do
    savon.expects(:get_storage).returns(:success)
    savon.expects(:update_storage).returns(:success)
    storage = Storage.find(:id => "f55952bc-da27-4e29-af89-ed212ea28e11")
    storage.update(:name => "Updated", :size => 10).should == true
    storage.name.should == "Updated"
    storage.size.should == 10
  end

  it "should be deleted" do
    savon.expects(:get_storage).with('<storageId>f55952bc-da27-4e29-af89-ed212ea28e11</storageId>').returns(:success)
    savon.expects(:delete_storage).with('<storageId>f55952bc-da27-4e29-af89-ed212ea28e11</storageId>').returns(:success)
    storage = Storage.find(:id => "f55952bc-da27-4e29-af89-ed212ea28e11")
    storage.delete.should == true
  end
end