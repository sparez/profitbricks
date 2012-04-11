require 'savon'
require 'profitbricks/profitbricks'
require 'profitbricks/extensions'
require 'profitbricks/config'
require 'profitbricks/model'
require 'profitbricks/data_center'
require 'profitbricks/server'
require 'profitbricks/image'
require 'profitbricks/storage'
require 'profitbricks/ip_block'
require 'profitbricks/load_balancer'
require 'profitbricks/firewall'
require 'profitbricks/rule'

module Profitbricks
  VERSION = '0.5.1'
end

PB = Profitbricks