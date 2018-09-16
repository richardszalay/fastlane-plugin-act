module Fastlane
  module ActHelper
    class FilePatcher
      def self.replace(archive, file_values)
        file_values.each do |old_file, new_file|
          UI.message("Replacing #{old_file}")

          relative_path = archive.app_path(old_file)
          local_path = archive.local_path(relative_path)
          `cp #{new_file.shellescape} #{local_path.shellescape}`
          archive.replace(relative_path)
        end
      end

      def self.remove(archive, file_values)
        file_values.each do |file_to_delete|
          UI.message("Deleting #{file_to_delete}")

          relative_path = archive.app_path(file_to_delete)
          local_path = archive.local_path(relative_path)
          File.delete(local_path)
          archive.replace(relative_path)
        end
      end
    end
  end
end
