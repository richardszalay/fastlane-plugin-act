module Fastlane
  module ActHelper
    class ArchivePaths
      def self.expand(archive, path)
        path_dup = path.dup
        path_dup = archive.app_path(path_dup) unless path_dup.start_with?("/")
        path_dup[0] = '' if path_dup.start_with?("/")
        path_dup
      end
    end
  end
end
