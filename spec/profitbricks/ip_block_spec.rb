require 'spec_helper'

describe Profitbricks::IpBlock do
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

  it "should reserve a block" do
    savon.expects(:reserve_public_ip_block).returns(:success)
    IpBlock.reserve(2).should == true
  end

  it "should list all available blocks" do
    savon.expects(:get_all_public_ip_blocks).returns(:success)
    blocks = IpBlock.all()
    blocks.count.should == 1
    blocks.first.ips.count.should == 2
  end

  it "should release a block properly" do 
    savon.expects(:get_all_public_ip_blocks).returns(:success)
    savon.expects(:release_public_ip_block).returns(:success)
    blocks = IpBlock.all()
    blocks.first.release.should == true
  end

end