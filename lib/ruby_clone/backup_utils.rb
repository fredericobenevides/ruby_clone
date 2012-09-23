require 'fileutils'
require 'find'

module RubyClone

  module BackupUtils

    def self.delete_files(path, ruby_clone_suffix, limit)
      finder = @find || Find

      find_files_with_same_name finder, path, ruby_clone_suffix
      delete_files_reached_the_limit limit
    end

   private

    def self.find_files_with_same_name(finder, path, ruby_clone_suffix)
      @paths = {}

      finder.find(path) do |path|
        path_without_suffix = path.sub(/#{ruby_clone_suffix}.*/, '')

        @paths[path_without_suffix] ||= []
        @paths[path_without_suffix] << path
      end
    end

    def self.delete_files_reached_the_limit(limit)
      file_utils = @file_utils || FileUtils
      @paths.each_value do |files|
        if files.size > limit
          files.slice(limit, files.size).each do |file|
            file_utils.remove_entry file
          end
        end
      end
    end
  end
end