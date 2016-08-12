module Fastlane
  module Actions
    class ActAction < Action
      def self.run(params)
        params[:ipa] = File.expand_path params[:ipa]
        raise "IPA #{params[:ipa]} does not exist" unless File.exist? params[:ipa]

        params[:app_name] = (File.basename params[:ipa], ".*") + ".app" unless params[:app_name]

        create_temp_dir = params[:temp_dir].nil?
        params[:temp_dir] = Dir.mktmpdir if create_temp_dir
        UI.verbose("Working in temp dir: #{params[:temp_dir]}")

        archive = ActHelper::IPAArchive.new params[:ipa], params[:app_name], params[:temp_dir]

        raise "IPA does not contain Payload/#{params[:app_name]}. Rename the .ipa to match the .app, or provide an app_name option value" unless archive.contains

        params[:plist_file] = "Info.plist" unless params[:plist_file]

        ActHelper::PlistPatcher.patch(
          archive,
          params[:plist_file],
          params[:plist_values],
          params[:plist_commands]
        ) if params[:plist_values] or params[:plist_commands]

        ActHelper::IconPatcher.patch(
          archive,
          params[:iconset],
          !params[:skip_delete_icons]
        ) if params[:iconset]

        if create_temp_dir
          UI.verbose("Removing temp dir")
          `rm -rf #{params[:temp_dir]}`
        end
      end

      def self.description
        "Reconfigures .plists and icons inside a compiled IPA"
      end

      def self.authors
        ["Richard Szalay"]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :ipa,
                                  env_name: "FACELIFT_IPA",
                               description: "Path of the IPA file being modified",
                                  optional: false,
                                      type: String),

          FastlaneCore::ConfigItem.new(key: :iconset,
                               description: "Path to iconset to swap into the IPA (ignores :plist option)",
                                  optional: true,
                                      type: String),

          FastlaneCore::ConfigItem.new(key: :plist_file,
                                  env_name: "FACELIFT_PLIST_FILE",
                               description: "The name of the plist file to modify, relative to the .app bundle`",
                                  optional: true,
                             default_value: "Info.plist",
                                      type: String),

          FastlaneCore::ConfigItem.new(key: :plist_values,
                               description: "Hash of plist values to set to the plist file",
                                  optional: true,
                                      type: Hash),

          FastlaneCore::ConfigItem.new(key: :plist_commands,
                               description: "Array of PlistBuddy commands to invoke",
                                  optional: true,
                                      type: Array),

          # TODO: :force flag for ignoring command errors and auto-adding plist_values if non-existant

          # Very optional
          FastlaneCore::ConfigItem.new(key: :app_name,
                                  env_name: "FACELIFT_APP_NAME",
                               description: "The name of the .app file (including extension), if not the same as the IPA",
                                  optional: true,
                                      type: String),

          FastlaneCore::ConfigItem.new(key: :temp_dir,
                                  env_name: "FACELIFT_TEMP_DIR",
                               description: "The temporary directory to work from. One will be created if not supplied",
                                  optional: true,
                                      type: String),

          FastlaneCore::ConfigItem.new(key: :skip_delete_icons,
                                    env_name: "FACELIFT_SKIP_DELETE_ICONS",
                                 description: "When true, the old icon files will not be deleted from the IPA",
                                    optional: true,
                                default_value: false,
                                        type: [TrueClass, FalseClass])
        ]
      end

      def self.is_supported?(platform)
        [:ios].include?(platform)
      end
    end
  end
end
