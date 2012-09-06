module RubyClone

  class FromFolder
    attr_accessor :folder

    def initialize(folder)
      @folder = folder
    end

    def to_s
      @folder
    end
  end

  class ToFolder
    attr_accessor :folder

    def initialize(folder)
      @folder = folder
    end

    def to_s
      @folder
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