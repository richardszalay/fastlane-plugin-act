module Fastlane
  module ActHelper
    class IPAArchive
      def initialize(ipa_file, app_name = null, temp_dir = null)
        @ipa_file = ipa_file
        
        @create_temp_dir = temp_dir.nil?
        @temp_dir = Dir.mktmpdir if @create_temp_dir
        UI.verbose("Working in temp dir: #{@temp_dir}")

        @app_path = "Payload/#{app_name}" if app_name
        @app_path = IPAArchive.extract_app_path(@ipa_file) unless app_name

        raise "IPA does not contain #{@app_path}" unless contains("#{@app_path}/")
      end

      # Returns the full path to the given file that can be modified
      def local_path(path)
        "#{@temp_dir}/#{path}"
      end

      # Returns an archive-relative path to the given application file
      def app_path(path)
        "#{@app_path}/#{path}"
      end

      # Extract files to the temp dir
      def extract(path)
        UI.verbose("Extracting #{path}")

        Dir.chdir(@temp_dir) do
          result = `unzip -o -q #{@ipa_file.shellescape} #{path.shellescape}`

          if $?.exitstatus.nonzero?
            UI.important result
            raise "extract operation failed with exit code #{$?.exitstatus}"
          end
        end
      end

      # Restore extracted files from the temp dir
      def replace(path)
        UI.verbose("Replacing #{path}")
        Dir.chdir(@temp_dir) do
          `zip -q #{@ipa_file.shellescape} #{path.shellescape}`
        end
      end

      # Delete path inside the ipa
      def delete(path)
        UI.verbose("Deleting #{path}")
        Dir.chdir(@temp_dir) do
          `zip -dq #{@ipa_file.shellescape} #{path.shellescape}`
        end
      end

      def contains(path = nil)
        `zipinfo -1 #{@ipa_file.shellescape} #{path.shellescape}`
        $?.exitstatus.zero?
      end

      def clean
        `rm -rf #{temp_dir.shellescape}` if @create_temp_dir
        `rm -rf #{temp_dir.shellescape}/*` unless @create_temp_dir
      end

      def self.extract_app_path(archive_path)
        `zipinfo -1 #{archive_path.shellescape} "Payload/*.app/" | sed -n '1 p'`.strip().chomp('/')
      end
    end
  end
end
