# -*- ruby -*-

require 'rubygems'
require 'hoe'
require "rspec/core/rake_task"

# Hoe.plugin :compiler
# Hoe.plugin :gem_prelude_sucks
# Hoe.plugin :inline
# Hoe.plugin :racc
# Hoe.plugin :rubyforge
Hoe.plugin :git
Hoe.plugin :gemspec
Hoe.plugin :bundler

Hoe.spec 'profitbricks' do
  developer('Dominik Sander', 'git@dsander.de')

  self.readme_file = 'README.md'
  self.history_file = 'CHANGELOG.md'
end

task :prerelease => [:clobber, :check_manifest, :test]

RSpec::Core::RakeTask.new

task :default => :spec
task :test => :spec