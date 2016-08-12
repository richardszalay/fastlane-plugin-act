describe Fastlane::Actions::ActAction do
  describe '#run' do
    before(:context) do
      @tmp_dir = Dir.mktmpdir
      @ipa_file = File.join(@tmp_dir, "Example.ipa")

      Dir.chdir("example/layout/") do
        `zip #{@ipa_file} -r *`
      end
    end

    after(:context) do
      FileUtils.rm_rf(@tmp_dir)
    end

    context 'providing plist values' do
      it 'defaults to info.plist' do
        Fastlane::Actions::ActAction.run(
          ipa: @ipa_file,
          plist_values: {
            ":CustomApplicationKey" => "Replaced"
          }
        )

        result = invoke_plistbuddy("Print :CustomApplicationKey", "Payload/Example.app/Info.plist")

        expect(result).to eql("Replaced")
      end

      it 'can use a different plist' do
        Fastlane::Actions::ActAction.run(
          ipa: @ipa_file,

          plist_file: "GoogleService-Info.plist",

          plist_values: {
            ":TRACKING_ID" => "UA-22222222-22"
          }
        )

        result = invoke_plistbuddy("Print :TRACKING_ID", "Payload/Example.app/GoogleService-Info.plist")

        expect(result).to eql("UA-22222222-22")
      end
    end

    context 'providing plist commands' do
      it 'defaults to info.plist' do
        Fastlane::Actions::ActAction.run(
          ipa: @ipa_file,
          plist_commands: [
            "Add :NewKey string NewValue"
          ]
        )

        result = invoke_plistbuddy("Print :NewKey", "Payload/Example.app/Info.plist")

        expect(result).to eql("NewValue")
      end

      it 'can use a different plist' do
        Fastlane::Actions::ActAction.run(
          ipa: @ipa_file,

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
          ipa: @ipa_file,
          iconset: "example/Blue.appiconset"
        )

        result = archive_contains("Payload/Example.app/Orange29x29@2x.png")

        expect(result).to be false
      end

      it 'adds new icon files' do
        Fastlane::Actions::ActAction.run(
          ipa: @ipa_file,
          iconset: "example/Blue.appiconset"
        )

        result = archive_contains("Payload/Example.app/Blue29x29@2x.png")

        expect(result).to be true
      end

      it 'modifies the Info.plist' do
        Fastlane::Actions::ActAction.run(
          ipa: @ipa_file,
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
          ipa: @ipa_file,
          plist_file: "GoogleService-Info.plist",
          iconset: "example/Blue.appiconset"
        )

        result = archive_contains("Payload/Example.app/Blue29x29@2x.png")

        expect(result).to be true
      end
    end

    def invoke_plistbuddy(command, plist)
      Dir.mktmpdir do |dir|
        Dir.chdir dir do
          `unzip -o -q #{@ipa_file} #{plist}`

          return `/usr/libexec/PlistBuddy -c "#{command}" "#{plist}"`.strip
        end
      end
    end

    def archive_contains(path)
      Dir.mktmpdir do |dir|
        Dir.chdir dir do
          `zipinfo -1 #{@ipa_file} #{path} 2>&1`

          return $?.exitstatus.zero?
        end
      end
    end
  end
end
