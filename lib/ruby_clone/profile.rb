module RubyClone

  class FromFolder
    attr_accessor :path

    def initialize(path)
      @exclude_paths = []
      @path = path
    end

    def exclude_paths
      @exclude_paths
    end

    def exclude_paths=(path)
      @exclude_paths << path
    end

    def to_s
      @path
    end
  end

  class ToFolder
    attr_accessor :path

    def initialize(path)
      @path = path
    end

    def to_s
      @path
    end
  end

  class Profile
    attr_accessor :name
    attr_accessor :from_folder
    attr_accessor :to_folder

    def initialize(name)
      @name = name
    end

    def to_s
      @name
    end
  end

end