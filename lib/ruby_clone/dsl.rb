module RubyClone

  module DSL

    def profile(name, &block)
      @rsync ||= RubyClone::RSync.new

      profile = Profile.new(name)

      if block
        @rsync.profiles = profile
        called_block = block.call

        raise SyntaxError, 'Empty Profile not allowed' if not called_block
      else
        raise SyntaxError, 'Empty Profile not allowed'
      end

      profile
    end

    def from(folder)
      from_folder = FromFolder.new(folder)
      @rsync.last_profile.from_folder = from_folder
    end

    def to(folder)
      to_folder = ToFolder.new(folder)
      @rsync.last_profile.to_folder = to_folder
    end

  end
end