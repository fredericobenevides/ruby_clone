require 'open4'

module RubyClone

  class RSync

    attr_accessor :profiles
    attr_accessor :rsync_options

    def initialize
      @exclude_paths = []
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
      profile = @profiles[profile_name]
      from_folder = profile.from_folder
      to_folder = profile.to_folder

      "rsync #{@rsync_options} #{create_exclude_command(profile)} #{from_folder} #{to_folder}".gsub(/\s+/, " ")
    end

    def run(profile_name)
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
  end
end