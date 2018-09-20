module Fastlane
  module ActHelper
    class ArchivePaths
      def self.expand(archive, path)
        path = archive.app_path(path) unless path.start_with?("/")
        path[0] = '' if path.start_with?("/")
        path
      end
    end
  end
end
