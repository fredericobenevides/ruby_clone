module RubyClone

  module DSL

    lambda {

      rsync = RubyClone::RSync.new

      define_method :run_backup do |profile|
        rsync.run profile
      end

      define_method :profile do |name, &block|
        rsync ||= RubyClone::RSync.new

        profile = Profile.new(name)

        if block
          rsync.profiles = profile
          called_block = block.call

          raise SyntaxError, 'Empty Profile not allowed' if not called_block
        else
          raise SyntaxError, 'Empty Profile not allowed'
        end

        profile
      end

      define_method :from do |folder|
        from_folder = FromFolder.new(folder)
        rsync.last_profile.from_folder = from_folder
      end

      define_method :to do |folder|
        to_folder = ToFolder.new(folder)
        rsync.last_profile.to_folder = to_folder
      end

    }.call

  end
end