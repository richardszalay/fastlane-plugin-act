module Fastlane
  module ActHelper
    class IconPatcher
      def self.patch(archive, iconset_path, delete_old_iconset)
        plist_path = archive.app_path("Info.plist")
        archive.extract(plist_path)

        UI.message("Patching icons from: #{iconset_path}")

        plist_buddy = PlistBuddy.new archive.local_path(plist_path)

        self.delete_icons(archive, plist_buddy, delete_old_iconset)

        icon_list = get_icons_from_iconset(iconset_path)
        icon_list.group_by { |i| i[:idiom] }.each do |idiom, icons|
          idiom_suffix = idiom == "iphone" ? "" : "~#{idiom}"
          icons_plist_key = ":CFBundleIcons#{idiom_suffix}:CFBundlePrimaryIcon:CFBundleIconFiles"

          plist_buddy.exec("Add #{icons_plist_key} array")

          icons.each do |i|
            relative_path = archive.app_path( (i[:target]).to_s )
            local_path = archive.local_path(relative_path)
            `cp #{i[:source].shellescape} #{local_path.shellescape}`
            archive.replace(relative_path)
          end

          icons.map { |i| i[:name] }.uniq.each_with_index do |key, index|
            plist_buddy.exec("Add #{icons_plist_key}:#{index} string #{key}")
          end
        end

        archive.replace(plist_path)
      end

      def self.get_icons_from_iconset(icon_set_path)
        icon_set = File.basename(icon_set_path, ".*")

        icon_set_manifest_file = File.expand_path "#{icon_set_path}/Contents.json"
        raise ".iconset manifest #{icon_set_manifest_file} does not exist" unless File.exist? icon_set_manifest_file

        icon_set_manifest = JSON.parse(File.read(icon_set_manifest_file))

        valid_icon_images = icon_set_manifest["images"].select { |image| image['filename'] }

        return valid_icon_images.map do |entry|
          scale_suffix = entry['scale'] == '1x' ? '' : "@" + entry['scale']
          idiom_suffix = entry['idiom'] == "iphone" ? '' : "~" + entry['idiom']
          file_extension = File.extname(entry['filename'])

          {
            source: "#{icon_set_path}/#{entry['filename']}",
            name: "#{icon_set}#{entry['size']}",
            idiom: entry['idiom'],
            target: "#{icon_set}#{entry['size']}#{scale_suffix}#{idiom_suffix}#{file_extension}"
          }
        end
      end

      def self.delete_icons(archive, plist_buddy, delete_old_iconset)
        existing_icon_set_keys = plist_buddy.parse_dict_keys(plist_buddy.exec("Print"))
                                            .map { |k| k.match(/^CFBundleIcons(~.+)?$/) }
                                            .select { |m| m }

        existing_icon_set_keys.each do |match|
          key = match[0]
          idiom_suffix = match[1]

          icon_list_key = ":#{key}:CFBundlePrimaryIcon:CFBundleIconFiles"

          begin
            icon_files_value = plist_buddy.exec "Print #{icon_list_key}"
          rescue
            next
          end

          existing_icons = plist_buddy.parse_scalar_array(icon_files_value)

          if existing_icons.size && delete_old_iconset
            icons_to_delete = existing_icons.map { |name| archive.app_path("#{name}#{idiom_suffix}*") }

            icons_to_delete.each do |icon_to_delete|
              archive.delete icon_to_delete
            end

          end

          plist_buddy.exec "Delete #{icon_list_key}"
        end
      end
    end
  end
end
