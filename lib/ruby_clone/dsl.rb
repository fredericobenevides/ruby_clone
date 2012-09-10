module RubyClone

  module DSL

    def profile(name, &block)
      @profile = Profile.new(name)

      called_block = block.call if block
      raise SyntaxError, 'Empty Profile not allowed' if not called_block

      @profile
    end

    def from(folder)
      from_folder = FromFolder.new(folder)
      @profile.from_folder = from_folder
    end

    def to(folder)
      to_folder = ToFolder.new(folder)
      @profile.to_folder = to_folder
    end

  end
end