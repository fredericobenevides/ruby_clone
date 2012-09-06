require 'open4'

module RubyClone

  class RSync

    attr_accessor :profiles
    attr_accessor :rsync_options

    def initialize
      @profiles = {}
      @rsync_options = '-Cav --stats'
    end

    def profiles=(profile)
      @profiles[profile.name] = profile
    end

    def run(profile_name)
      profile = @profiles[profile_name]

      open4 = @open4 || Open4

      open4::popen4("sh") do |pid, stdin, stdout, stderr|
        stdin.puts rsync_command(profile.from_folder, profile.to_folder)
        stdin.close

        puts stdout.read
        puts stderr.read
      end
    end

   private

    def rsync_command(from_folder, to_folder)
      "rsync #{@rsync_options} #{from_folder} #{to_folder}"
    end
  end
end