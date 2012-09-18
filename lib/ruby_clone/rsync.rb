require 'open4'

module RubyClone

  class RSync

    attr_accessor :profiles
    attr_accessor :rsync_options
    attr_accessor :show_rsync_command

    def initialize(output)
      @exclude_paths = []
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

    def rsync_command(profile_name)
      profile = @profiles[profile_name.to_s]

      if profile
        from_folder = profile.from_folder
        to_folder = profile.to_folder

        raise SyntaxError, "Empty Profile not allowed for profile with no 'from folder'" unless from_folder
        raise SyntaxError, "Empty Profile not allowed for profile with no 'to folder'" unless to_folder

        "rsync #{@rsync_options} #{create_exclude_command(profile)} #{create_backup_command(profile)} #{from_folder} #{to_folder}".gsub(/\s+/, " ")
      else
        raise ArgumentError, "Profile not found"
      end
    end

    def run(profile_name)
      rsync_command = rsync_command(profile_name)
      @output.puts "\n#{rsync_command}\n\n" if @show_rsync_command

      open4 = @open4 || Open4

      open4::popen4("sh") do |pid, stdin, stdout, stderr|
        stdin.puts rsync_command(profile_name)
        stdin.close

        puts stdout.read
        puts stderr.read
      end
    end

   private

    def create_exclude_command(profile)
      excludes = ""
      if !@exclude_paths.empty?
        @exclude_paths.each do |path|
          excludes << "--exclude=#{path} "
        end
      end

      if !profile.from_folder.exclude_paths.empty?
        profile.from_folder.exclude_paths.each do |path|
          excludes << "--exclude=#{path} "
        end
      end
      excludes
    end

    def create_backup_command(profile)
      backup = profile.to_folder.backup
      backup.to_command if backup
    end
  end
end