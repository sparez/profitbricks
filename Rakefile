# -*- ruby -*-

require 'rubygems'
require 'hoe'
require "rspec/core/rake_task"

# Hoe.plugin :compiler
# Hoe.plugin :gem_prelude_sucks
# Hoe.plugin :inline
# Hoe.plugin :racc
# Hoe.plugin :rubyforge

Hoe.spec 'profitbricks' do
  # HEY! If you fill these out in ~/.hoe_template/Rakefile.erb then
  # you'll never have to touch them again!
  # (delete this comment too, of course)

  developer('Dominik Sander', 'git@dsander.de')

  # self.rubyforge_name = 'profitbricksx' # if different than 'profitbricks'
end

RSpec::Core::RakeTask.new

task :default => :spec
task :test => :spec