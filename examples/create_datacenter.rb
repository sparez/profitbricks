require 'pp'
require 'profitbricks'

Profitbricks.configure do |config|
  config.username = "username"
  config.password = "password"
end

# An example how to use the Profitbricks API
#
# We will create a small DataCenter with two Servers
# * one webserver connected to the internet
# * and a database server 
#

dc = DataCenter.create(:name => 'Example Project')
dc.wait_for_provisioning

debian = Image.find(:name => "profitbricks-debian-squeeze-EN-6.0.1a-amd64.img")
dc.wait_for_provisioning

hdd1 = Storage.create(:name => "Debian Webserver", :size => 10, :mount_image_id => debian.id, :data_center_id => dc.id)
dc.wait_for_provisioning

webserver = dc.create_server(:cores => 1, :ram => 256, :name => "Webserver", :boot_from_storage_id => hdd1.id, :lan_id => 2)
dc.wait_for_provisioning
webserver.reload

webserver_private_nic = webserver.nics.first
webserver_private_nic.update(:ip => "192.168.0.10")

ipblock = IpBlock.reserve(1)
ip = ipblock.ips.first

dc.wait_for_provisioning

public_nic = Nic.create(:server_id => webserver.id, :lan_id => 1, :ip => ip, :name => "Public")
dc.wait_for_provisioning

public_nic.set_internet_access = true
dc.wait_for_provisioning


hdd2 = Storage.create(:name => "Debian Database Server", :size => 10, :mount_image_id => debian.id, :data_center_id => dc.id)
dc.wait_for_provisioning

db_server = dc.create_server(:cores => 1, :ram => 256, :name => "Database Server", :lan_id => 2, :boot_from_storage_id => hdd2.id, :data_center_id => dc.id)
dc.wait_for_provisioning
db_server.reload

db_server_private_nic = db_server.nics.first
db_server_private_nic.update(:ip => "192.168.0.11")
dc.wait_for_provisioning

dc.reload

pp dc