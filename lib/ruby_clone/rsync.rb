require 'open4'

module RubyClone

  class RSync

    attr_accessor :profiles
    attr_accessor :rsync_options
    attr_accessor :show_rsync_command

    def initialize(output)
      @exclude_paths = []
      @include_patterns = []
      @output = output
      @show_rsync_command = true
      @profiles = {}
      @rsync_options = '-Cav --stats'
    end

    def profiles=(profile)
      @profiles[profile.name] = profile
      @last_profile = profile
    end

    def last_profile
      @last_profile
    end

    def exclude_paths=(path)
      @exclude_paths << path
    end

    def include_pattern=(path)
      @include_patterns << path
    end

    def rsync_command(profile_name)
      profile = @profiles[profile_name.to_s]

      if profile
        raise SyntaxError, "Empty Profile not allowed for profile with no 'from folder'" unless profile.from_folder
        raise SyntaxError, "Empty Profile not allowed for profile with no 'to folder'" unless profile.to_folder

        create_rsync_command profile
      else
        raise ArgumentError, "Profile not found"
      end
    end

    def run(profile_name)
      command = rsync_command(profile_name)
      @output.puts "\n#{command}\n\n" if @show_rsync_command

      open4 = @open4 || Open4

      open4::popen4("sh") do |pid, stdin, stdout, stderr|
        stdin.puts command
        stdin.close

        puts stdout.read
        puts stderr.read
      end
    end

   private

    def create_rsync_command(profile)
      command = "rsync #{@rsync_options} "

      command << @exclude_paths.map { |e| "--exclude=#{e}" }.join(" ")
      command << @include_patterns.map { |e| "--include=#{e}" }.join(" ")

      command << " #{profile.from_folder.to_command}"
      command << " #{profile.to_folder.to_command}"
      command << " #{create_ssh_command(profile)}"

      command << " #{profile.from_folder} #{profile.to_folder}"
      command.gsub(/\s+/, " ")
    end

    def create_ssh_command(profile)
      from_folder = profile.from_folder
      to_folder = profile.to_folder

      if from_folder.ssh? && to_folder.ssh?
        raise SyntaxError, 'The source and destination cannot both be remote.'
      elsif from_folder.ssh? || to_folder.ssh?
        "-e ssh"
      end
    end
  end
end