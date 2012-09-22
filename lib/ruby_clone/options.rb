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

        opts.on("-b", "--backup-file path", String, "Change the path to backup file (default is #{ENV['HOME']}/.ruby_clone)") do |backup_file|
          @configurations[:backup_file] = backup_file
        end

        opts.on("-d", "--dry-run", "Show what would have been transferred") do
          @configurations[:dry_run] = true
        end

        opts.on("-h", "--help", "This message") do
          @output.puts opts
        end

        argv = %w[-h] if argv.empty?
        opts.parse!(argv)
      end
      opts
    end

  end
end