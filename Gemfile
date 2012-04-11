source :rubygems
gem 'savon'

group :test, :development do 
  gem 'json'
  gem 'rspec'
  gem 'savon_spec'
  gem 'simplecov', :require => false
  gem 'rake'
  gem 'ZenTest'
  platforms :mri do
    gem 'autotest-fsevent'
    # Temporary fix till hoe works with rbx in 1.9 mode
    gem 'hoe'
    gem 'hoe-git'
    gem 'hoe-gemspec'
    gem 'hoe-bundler'
  end
end

platforms :jruby do
  gem 'jruby-openssl'
end