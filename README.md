# Profitbricks [![Build Status](https://secure.travis-ci.org/dsander/profitbricks.png)](http://travis-ci.org/dsander/profitbricks)

* http://github.com/dsander/profitbricks
* http://rubydoc.info/github/dsander/profitbricks/master/frames


## DESCRIPTION
A Ruby client for the ProfitBricks API.

BE AWARE: This software is in a very early state of development, the methods and responses will very likely change over time.

## Dependencies
A Ruby interpreter.
Currently only tested on MRI 1.9.3, more implementations will follow once the tests pass on TravisCI


## Installation
	gem install profitbricks


## Synopsis
	require 'profitbricks'
	Profitbricks.configure do |config|
		config.username = "username"
		config.password = "password"
	end

Get a list of all your Datacenters

	DataCenter.all

Create a new Datacenter

	dc = DataCenter.create('Name')

Find a Datacenter by name

	dc = DataCenter.find(:name => 'Name')

Create a new Server

	dc.create_server(:cores => 1, :ram => 256, :name => 'Test Server')

or

	Server.create(:cores => 1, :ram => 256, :name => 'Test Server')

Check out the examples directory for more detailed usage information.

## License
This might also change!

(The MIT License)

Copyright (c) 2012 Dominik Sander

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
