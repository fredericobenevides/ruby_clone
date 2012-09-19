module RubyClone

  class FromFolder
    attr_accessor :path

    def initialize(path, options = {})
      @exclude_paths = []
      @options = options
      @path = path
    end

    def exclude_paths=(path)
      @exclude_paths << path
    end

    def to_command
      @exclude_paths.map { |e| "--exclude=#{e}" }.join(" ")
    end

    def ssh?
     if @options[:ssh]
       true
     else
       false
     end
    end

    def to_s
      return "#{@options[:ssh]}:#{@path}" if @options[:ssh]
      return @path if not @options[:ssh]
    end
  end

  class ToFolder
    attr_accessor :backup
    attr_accessor :path

    def initialize(path, options = {})
      @path = path
      @options = options
    end

    def to_command
      command = ""
      command << "--delete " if @options[:delete]
      command << "--delete-excluded " if @options[:delete_excluded]

      command << backup.to_command if backup
      command.strip
    end

    def ssh?
      if @options[:ssh]
        true
      else
        false
      end
    end

    def to_s
      return "#{@options[:ssh]}:#{@path}" if @options[:ssh]
      return @path if not @options[:ssh]
    end
  end

  class Profile
    attr_accessor :name
    attr_accessor :from_folder
    attr_accessor :to_folder

    def initialize(name)
      @name = name.to_s
    end

    def to_s
      @name
    end
  end

  class Backup
    attr_accessor :path

    def initialize(path, options = {})
      @options = options
      @path = path
    end

    def to_command
      command = "-b "
      command << "--suffix=#{@options[:suffix]} " if @options[:suffix]
      command << "--backup-dir=#{path} "
      command.strip
    end

    def to_s
      @path
    end
  end

end