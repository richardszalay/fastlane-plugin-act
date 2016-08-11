module Fastlane
  module Helper
    class FaceliftHelper
      # class methods that you define here become available in your action
      # as `Helper::FaceliftHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the facelift plugin helper!")
      end
    end
  end
end
