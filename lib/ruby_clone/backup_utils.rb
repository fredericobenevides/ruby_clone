require 'fileutils'
require 'find'

module RubyClone

  module BackupUtils

    def self.delete_files(path, ruby_clone_suffix, limit)

      if File.exists?(path)
        paths = find_files_with_same_name path, ruby_clone_suffix
        delete_files_reached_the_limit paths, limit
      end
    end

    def self.find_files_with_same_name(path, ruby_clone_suffix)
      paths = {}

      Find.find(path) do |path|
        path_without_suffix = path.sub(/#{ruby_clone_suffix}.*/, '')

        if FileTest.file? path
          paths[path_without_suffix] ||= []
          paths[path_without_suffix] << path
        end
      end

      paths
    end

    def self.delete_files_reached_the_limit(paths, limit)
      paths.each_value do |files|
        if files.size > limit
          files.slice(0, files.size - limit).each do |file|
            FileUtils.remove_entry file
          end
        end
      end
    end
  end
end