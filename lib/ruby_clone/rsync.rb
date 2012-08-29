module RubyClone

  class RSync

    def initialize(source_folder, destiny_folder)
      @source_folder, @destiny_folder = source_folder, destiny_folder
    end

    def command
      "rsync -Cav #{@source_folder} #{@destiny_folder}"
    end
  end
end