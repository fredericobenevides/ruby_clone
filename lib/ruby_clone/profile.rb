module RubyClone

  class FromFolder
    attr_accessor :path

    def initialize(path, options = {})
      @exclude_patterns = []
      @include_patterns = []
      @options = options
      @path = path
    end

    def exclude_pattern=(path)
      @exclude_patterns << path
    end

    def include_pattern=(path)
      @include_patterns << path
    end

    def to_command
      command = ""
      command << @include_patterns.map { |e| "--include=#{e}" }.join(" ") + " "
      command << @exclude_patterns.map { |e| "--exclude=#{e}" }.join(" ")
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

    def initialize(path, options = { disable_suffix: false })
      @default_suffix = '_rbcl'
      @options = options
      @path = path
    end

    def to_command
      command = "-b "
      command << "#{create_suffix} " if not @options[:disable_suffix]
      command << "--backup-dir=#{path} "
      command.strip
    end

   private

    def create_suffix
      time = @time || Time.now.strftime("%Y%m%d")
      command = "--suffix="
      command << "#{@default_suffix}_#{time}" if not @options[:suffix]
      command << "#{@default_suffix}#{@options[:suffix]}" if @options[:suffix]
      command
    end

    def to_s
      @path
    end
  end

end