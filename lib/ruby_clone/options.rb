require 'optparse'

module RubyClone

  class Options
    attr_reader :configurations
    attr_reader :profile

    def initialize(output)
      @output = output
      @configurations = {}
      @configurations[:backup_file] = '~/.ruby_clone'
    end

    def parse(argv)
      opts = OptionParser.new do |opts|
        opts.banner = "Usage: ruby_clone [options] profile"

        opts.on("-h", "--help", "This message") do
          @output.puts opts
          #exit
        end

        opts.on("-b", "--backup-file path", String, "Path to backup file (default is $HOME/ruby_clone)") do |backup_file|
          @configurations[:backup_file] = backup_file
        end

        argv = %w[-h] if argv.empty?
        opts.parse!(argv)
      end
      opts
    end

  end
end