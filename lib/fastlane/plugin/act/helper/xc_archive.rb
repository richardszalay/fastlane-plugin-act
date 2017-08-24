module Fastlane
  module ActHelper
    class XCArchive
      def initialize(xcarchive_path, app_name)
        @xcarchive_path = xcarchive_path
        
        @app_path = "Products/Applications/#{app_name}" if app_name
        @app_path = "Products/#{XCArchive.extract_app_path(xcarchive_path)}" unless app_name
      end

      # Returns the full path to the given file that can be modified
      def local_path(path)
        "#{@xcarchive_path}/#{path}"
      end

      # Returns an archive-relative path to the given application file
      def app_path(path)
        "#{@app_path}/#{path}"
      end

      # Extract files to the temp dir
      def extract(path)
      end

      # Restore extracted files from the temp dir
      def replace(path)
      end

      # Delete path inside the ipa
      def delete(path)
        UI.verbose("Deleting #{path}")

        Dir.glob(local_path(path)).each { |f| File.delete(f) }
      end

      def contains(path = nil)
        File.exist? local_path(path)
      end

      def clean
        `rm -rf #{temp_dir.shellescape}/*`
      end

      def self.extract_app_path(archive_path)
        plist_buddy = PlistBuddy.new "#{archive_path}/Info.plist"

        (plist_buddy.exec "Print :ApplicationProperties:ApplicationPath").strip
      end
    end
  end
end
