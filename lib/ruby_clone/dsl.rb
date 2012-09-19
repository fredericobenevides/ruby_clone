module RubyClone

  module DSL

    lambda {

      rsync = RubyClone::RSync.new(STDOUT)
      current_object = rsync

      define_method :current_rsync do
        rsync
      end

      define_method :rsync_new_instance do
        rsync = RubyClone::RSync.new(STDOUT)
        current_object = rsync
      end

      define_method :run_backup do |profile|
        rsync.run profile
      end

      define_method :profile do |name, &block|
        profile = Profile.new(name)
        current_object = profile

        if block
          rsync.profiles = profile
          called_block = block.call

          raise SyntaxError, 'Empty Profile not allowed' if not called_block
        else
          raise SyntaxError, 'Empty Profile not allowed'
        end

        current_object = rsync
      end

      define_method :from do |folder, options = {}, &block|
        from_folder = FromFolder.new(folder, options)
        current_object = from_folder

        rsync.last_profile.from_folder = from_folder

        block.call if block
        current_object = rsync
      end

      define_method :to do |folder, options = {}, &block|
        to_folder = ToFolder.new(folder, options)
        current_object = to_folder

        rsync.last_profile.to_folder = to_folder

        block.call if block
        current_object = rsync
      end

      define_method :backup do |path, options = {}|
        backup = Backup.new(path, options)
        current_object.backup = backup
      end

      define_method :exclude_pattern do |path|
        current_object.exclude_pattern = path
      end

      define_method :include_pattern do |path|
        current_object.include_pattern = path
      end

      define_method :show_rsync_command do |value|
        current_object.show_rsync_command = value
      end

    }.call

  end
end