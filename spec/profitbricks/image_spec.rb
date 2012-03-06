require 'spec_helper'

describe Profitbricks::Image do
  include Savon::Spec::Macros

  it "should find all images" do
    savon.expects(:get_all_images).returns(:success)
    Image.all.count.should == 7
  end

  it "should find an image by name" do 
  	savon.expects(:get_all_images).returns(:success)
  	image = Image.find(:name => "Windows8-ConsumerPreview-64bit-English.iso")
    image.os_type.should == "UNKNOWN"
  end

  it "should update the os_type" do
    savon.expects(:get_all_images).returns(:success)
    savon.expects(:set_image_os_type).returns(:success)
    image = Image.find(:name => "Windows8-ConsumerPreview-64bit-English.iso")
    image.set_os_type("WINDOWS").os_type.should == "WINDOWS"
  end
end