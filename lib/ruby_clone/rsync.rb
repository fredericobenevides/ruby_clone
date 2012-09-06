require 'open4'

module RubyClone

  class RSync

    def initialize(source_folder, destiny_folder)
      @source_folder, @destiny_folder = source_folder, destiny_folder
    end

    def command
      "rsync -Cav --stats #{@source_folder} #{@destiny_folder}"
    end

    def run
      open4 = @open4 || Open4

      open4::popen4("sh") do |pid, stdin, stdout, stderr|
        stdin.puts command
        stdin.close

        puts stdout.read
        puts stderr.read
      end

    end
  end
end