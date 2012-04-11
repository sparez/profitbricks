require 'optparse'
require 'pp'

module Profitbricks
  class CLI
    attr_accessor :stdout

    def initialize(stdout = $stdout)
      @options = {:debug => false}
      @stdout = stdout
    end

    def run(options)
      options = OptionParser.new do |opts|
        opts.banner = "Usage: profitbricks [options] <class> <method> argument=value argument2=value2 .."
        opts.separator ""
        opts.separator "You have to supply your Profitbricks user name and password in the environmental variables PROFITBRICKS_USER and PROFITBRICKS_PASSWORD"
        opts.separator ""
        opts.on("-d", "--debug", "Enable debugging output") do |d|
          @options[:debug] = d
        end
        opts.on_tail("-h", "--help", "Show this message") do
          @stdout.puts opts
          return -1
        end
        if !ENV['PROFITBRICKS_USER'] or !ENV['PROFITBRICKS_PASSWORD'] or options.length < 2
          @stdout.puts opts
          return -1
        end

      end.parse!(options)

      Profitbricks.configure do |config|
        config.username = ENV['PROFITBRICKS_USER']
        config.password = ENV['PROFITBRICKS_PASSWORD']
        config.log = @options[:debug]
      end
      
      (klass, m, arguments) = convert_arguments(options)

      begin
        klass = Profitbricks.get_class(klass)
      rescue LoadError
        @stdout.puts "Invalid class name #{klass}."
        return -1
      end
      
      if method = get_singleton_method(klass, m)
        dump = PP.pp(call_singleton_method(klass, m, arguments), "")
        @stdout.puts dump
      elsif method = get_instance_method(klass, m)
        dump = PP.pp(call_instance_method(klass, m, arguments), "")
        @stdout.puts dump
      else
        @stdout.puts "#{klass} has no method #{m}"
        return -1
      end
      return 0
    end


    def convert_arguments(options)
      arguments = Hash[options[2..-1].collect { |x| 
        a = x.split('=');
        a[1] = a[1].to_i if a[1] =~ /^\d+$/
        [a[0].to_sym, a[1]]  
      }]
      [options[0], options[1], arguments]
    end
    
    def get_singleton_method(klass, method)
      methods = klass.singleton_methods(false)
      if methods.collect { |m| m.to_sym }.include?(method.to_sym)
        return klass.method(method.to_sym)
      end
    end

    def get_instance_method(klass, method)
      obj = klass.send(:new, {})
      methods = obj.public_methods(false)
      if methods.collect { |m| m.to_sym }.include?(method.to_sym)
        return obj.method(method)
      end
    end

    def call_singleton_method(klass, method, arguments)
      call_method(klass, method, arguments)
    end

    def call_instance_method(klass, method, arguments)
      id = arguments.delete(:id)
      obj = klass.send(:find, {:id => id})
      call_method(obj, method, arguments)
    end

    def call_method(klass, method, arguments)
      if arguments.length > 0
        klass.send(method, arguments)
      else
        klass.send(method)
     end
   end

    class << self
    end
  end
end