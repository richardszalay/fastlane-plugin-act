module Fastlane
  module ActHelper
    class PlistPatcher
      def self.patch(archive, plist_path, values, commands)
        archive.extract(plist_path)

        UI.message("Patching Plist: #{plist_path}")

        plist_buddy = PlistBuddy.new archive.local_path(plist_path)

        values.each do |key, value|
          plist_buddy.exec "Set #{key} #{value}"
        end if values

        commands.each do |command|
          plist_buddy.exec command
        end if commands

        archive.replace(plist_path)
      end
    end
  end
end
