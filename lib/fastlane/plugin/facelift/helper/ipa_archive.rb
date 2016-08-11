module Fastlane
  module Helper
    class IPAArchive
      def initialize(ipa_file, app_name, temp_dir)
        @ipa_file = ipa_file
        @app_path = "Payload/#{app_name}"
        @temp_dir = temp_dir
      end

      # Returns the full path to the given file within the temp dir
      def local_path(path)
        "#{@temp_dir}/#{@app_path}/#{path}"
      end

      # Extract files to the temp dir
      def extract(path)
        UI.verbose("Extracting #{@app_path}/#{path}")

        Dir.chdir(@temp_dir) do
          result = `unzip -o -q #{@ipa_file} #{@app_path}/#{path}`

          if $?.exitstatus.nonzero?
            UI.important result
            raise "extract operation failed with exit code #{$?.exitstatus}"
          end
        end
      end

      # Restore extracted files from the temp dir
      def replace(path)
        UI.verbose("Replacing #{@app_path}/#{path}")
        Dir.chdir(@temp_dir) do
          `zip -q #{@ipa_file} #{@app_path}/#{path}`
        end
      end

      # Delete path inside the ipa
      def delete(path)
        UI.verbose("Deleting #{@app_path}/#{path}")
        Dir.chdir(@temp_dir) do
          `zip -dq #{@ipa_file} #{@app_path}/#{path}`
        end
      end

      def contains(path = nil)
        `zipinfo -1 #{@ipa_file} #{@app_path}/#{path}`
        $?.exitstatus.zero?
      end

      def clean
        `rm -rf #{temp_dir}/*`
      end
    end
  end
end
