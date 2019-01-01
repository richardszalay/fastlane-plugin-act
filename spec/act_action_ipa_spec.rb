describe Fastlane::Actions::ActAction do
  describe '#run' do
    describe 'ipa' do
      before do
        @tmp_dir = Dir.mktmpdir
        @tmp_dir = File.join(@tmp_dir, "dir with spaces")
        Dir.mkdir @tmp_dir

        @ipa_file = File.join(@tmp_dir, "Example.ipa")

        Dir.chdir("example/layout/") do
          `zip #{@ipa_file.shellescape} -r *`
        end
      end

      after do
        FileUtils.rm_rf(@tmp_dir)
      end

      context 'providing plist values' do
        it 'defaults to info.plist' do
          Fastlane::Actions::ActAction.run(
            archive_path: @ipa_file,
            plist_values: {
              ":CustomApplicationKey" => "Replaced"
            }
          )

          result = invoke_plistbuddy("Print :CustomApplicationKey", "Payload/Example.app/Info.plist")

          expect(result).to eql("Replaced")
        end

        it 'can use a different plist' do
          Fastlane::Actions::ActAction.run(
            archive_path: @ipa_file,

            plist_file: "GoogleService-Info.plist",

            plist_values: {
              ":TRACKING_ID" => "UA-22222222-22"
            }
          )

          result = invoke_plistbuddy("Print :TRACKING_ID", "Payload/Example.app/GoogleService-Info.plist")

          expect(result).to eql("UA-22222222-22")
        end

        it 'can use a plist outside the app_dir' do
          Fastlane::Actions::ActAction.run(
            archive_path: @ipa_file,

            plist_file: "/Info.plist",

            plist_values: {
              ":ApplicationProperties:CFBundleIdentifier" => "com.richardszalay.somethingelse"
            }
          )

          result = invoke_plistbuddy("Print :ApplicationProperties:CFBundleIdentifier", "Info.plist")

          expect(result).to eql("com.richardszalay.somethingelse")
        end

        it 'can override app name' do
          renamed_ipa_file = File.join(@tmp_dir, "NotExample.ipa")
          FileUtils.mv(@ipa_file, renamed_ipa_file)

          @ipa_file = renamed_ipa_file

          Fastlane::Actions::ActAction.run(
            archive_path: renamed_ipa_file,
            app_name: 'Example.app',
            plist_values: {
              ":CustomApplicationKey" => "Replaced"
            }
          )

          result = invoke_plistbuddy("Print :CustomApplicationKey", "Payload/Example.app/Info.plist")

          expect(result).to eql("Replaced")
        end
      end

      context 'providing plist commands' do
        it 'defaults to info.plist' do
          Fastlane::Actions::ActAction.run(
            archive_path: @ipa_file,
            plist_commands: [
              "Add :NewKey string NewValue"
            ]
          )

          result = invoke_plistbuddy("Print :NewKey", "Payload/Example.app/Info.plist")

          expect(result).to eql("NewValue")
        end

        it 'can use a different plist' do
          Fastlane::Actions::ActAction.run(
            archive_path: @ipa_file,

            plist_file: "GoogleService-Info.plist",

            plist_commands: [
              "Add :NewKey string NewValue"
            ]
          )

          result = invoke_plistbuddy("Print :NewKey", "Payload/Example.app/GoogleService-Info.plist")

          expect(result).to eql("NewValue")
        end
      end

      context 'providing an iconset' do
        it 'deletes old icon files' do
          Fastlane::Actions::ActAction.run(
            archive_path: @ipa_file,
            iconset: "example/Blue.appiconset"
          )

          result = archive_contains("Payload/Example.app/Orange29x29@2x.png")

          expect(result).to be false
        end

        it 'can optionally not delete old icon files' do
          Fastlane::Actions::ActAction.run(
            archive_path: @ipa_file,
            iconset: "example/Blue.appiconset",
            skip_delete_icons: true
          )

          result = archive_contains("Payload/Example.app/Orange29x29@2x.png")

          expect(result).to be true
        end

        it 'adds new icon files' do
          Fastlane::Actions::ActAction.run(
            archive_path: @ipa_file,
            iconset: "example/Blue.appiconset"
          )

          result = archive_contains("Payload/Example.app/Blue29x29@2x.png")

          expect(result).to be true
        end

        it 'excludes images without filenames' do
          Fastlane::Actions::ActAction.run(
            archive_path: @ipa_file,
            iconset: "example/Blue.appiconset"
          )

          result = archive_contains("Payload/Example.app/Blue60x60@3x.png")

          expect(result).to be false
        end

        it 'modifies the Info.plist' do
          Fastlane::Actions::ActAction.run(
            archive_path: @ipa_file,
            iconset: "example/Blue.appiconset"
          )

          result = [
            invoke_plistbuddy("Print :CFBundleIcons:CFBundlePrimaryIcon:CFBundleIconFiles:0", "Payload/Example.app/Info.plist"),
            invoke_plistbuddy("Print :CFBundleIcons:CFBundlePrimaryIcon:CFBundleIconFiles:1", "Payload/Example.app/Info.plist")
          ]

          expect(result).to eql(["Blue29x29", "Blue40x40"])
        end

        # TODO: More tests for other idioms (ie. iPad icons). These are supported, but there's no tests yet

        it 'ignores :plist_file option' do
          Fastlane::Actions::ActAction.run(
            archive_path: @ipa_file,
            plist_file: "GoogleService-Info.plist",
            iconset: "example/Blue.appiconset"
          )

          result = archive_contains("Payload/Example.app/Blue29x29@2x.png")

          expect(result).to be true
        end
      end

      context 'replacing files' do
        it 'replaces app-relative files' do
          Fastlane::Actions::ActAction.run(
            archive_path: @ipa_file,
            replace_files: {
              "GoogleService-Info.plist" => "example/New-GoogleService-Info.plist"
            }
          )

          result = invoke_plistbuddy("Print :TRACKING_ID", "Payload/Example.app/GoogleService-Info.plist")

          expect(result).to eql("UA-123456789-12")
        end

        it 'replaces archive-relative files' do
          Fastlane::Actions::ActAction.run(
            archive_path: @ipa_file,
            replace_files: {
              "/Info.plist" => "example/New-Info.plist"
            }
          )

          result = invoke_plistbuddy("Print :SchemeName", "Info.plist")

          expect(result).to eql("NewExample")
        end

        it 'adds if there is no file to replace' do
          Fastlane::Actions::ActAction.run(
            archive_path: @ipa_file,
            replace_files: {
              "Foo.plist" => "example/Foo.plist"
            }
          )

          result = invoke_plistbuddy("Print :Foo", "Payload/Example.app/Foo.plist")

          expect(result).to eql("42")
        end
      end

      context 'delete files' do
        it 'deletes app-relative paths' do
          Fastlane::Actions::ActAction.run(
            archive_path: @ipa_file,
            remove_files: [
              "GoogleService-Info.plist"
            ]
          )

          result = archive_contains("Payload/Example.app/GoogleService-Info.plist")

          expect(result).to be false
        end

        it 'deletes archive-relative files' do
          Fastlane::Actions::ActAction.run(
            archive_path: @ipa_file,
            remove_files: [
              "/Info.plist"
            ]
          )

          result = archive_contains("Info.plist")

          expect(result).to be false
        end
      end

      def invoke_plistbuddy(command, plist)
        Dir.mktmpdir do |dir|
          Dir.chdir dir do
            `unzip -o -q #{@ipa_file.shellescape} #{plist.shellescape}`

            return `/usr/libexec/PlistBuddy -c "#{command}" "#{plist.shellescape}"`.strip
          end
        end
      end

      def archive_contains(path)
        Dir.mktmpdir do |dir|
          Dir.chdir dir do
            `zipinfo -1 #{@ipa_file.shellescape} #{path.shellescape} 2>&1`

            return $?.exitstatus.zero?
          end
        end
      end
    end
  end
end
