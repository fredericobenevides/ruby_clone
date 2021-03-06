require 'pty'

module RubyClone

  class RSync

    attr_writer :dry_run

    def initialize(output)
      @configurations = { options: '-Cavh --stats --progress', show_command: true, show_output: true }
      @exclude_patterns = []
      @include_patterns = []
      @output = output
      @profiles = {}
    end

    def profiles=(profile)
      @profiles[profile.name] = profile
      @last_profile = profile
    end

    def last_profile
      @last_profile
    end

    def update_configurations(configurations)
      @configurations.merge! configurations
    end

    def exclude_pattern=(path)
      @exclude_patterns << path
    end

    def include_pattern=(path)
      @include_patterns << path
    end

    def rsync_command(profile_name)
      profile = @profiles[profile_name.to_s]

      if profile
        raise SyntaxError, "Empty Profile not allowed for profile #{profile} with no 'from folder'" unless profile.from_folder
        raise SyntaxError, "Empty Profile not allowed for profile #{profile} with no 'to folder'" unless profile.to_folder

        create_rsync_command profile
      else
        raise ArgumentError, "Profile #{profile_name} not found"
      end
    end

    def run(profile_name)
      command = rsync_command(profile_name)
      @output.puts "\n#{command}\n\n" if @configurations[:show_command]

      run_with_pty command

      unless @dry_run
        profile = @profiles[profile_name.to_s]
        profile.to_folder.delete_files
      end
    end

   private

    def create_rsync_command(profile)
      command = "rsync #{@configurations[:options]} "

      command << "-n " if @dry_run

      command << @include_patterns.map { |e| "--include=#{e}" }.join(" ") + " "
      command << @exclude_patterns.map { |e| "--exclude=#{e}" }.join(" ")

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

    def run_with_pty(command)
      pty = @pty || PTY

      pty.spawn(command) do |r, w, pid|
        begin
          loop {
            buffer = ""
            output_password = false

            until r.eof? do
              char = r.getc
              buffer << char
              @output.print char

              if buffer.include?('Password:') || buffer.include?('password:') || buffer.include?('want to continue connecting (yes/no)')
                output_password = true
                break
              end
            end

            if output_password
              @output.print " "

              `stty -echo`
              w.printf(STDIN.gets)
              `stty echo`
            else
              break
            end
          }
        rescue Errno::EIO # GNU/Linux raises EIO.
        end
      end

    end

  end
end