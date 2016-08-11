# facelift plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-facelift)

## Getting Started

This project is a [fastlane](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-facelift`, add it to your project by running:

```bash
fastlane add_plugin facelift
```

## About facelift

Applies changes to plists and app icons inside a compiled IPA, combined with sigh's `resign` it makes it easy to release an IPA with different configurations 🎭

## Example

Check out the [example `Fastfile`](fastlane/Fastfile) to see how to use this plugin. Try it by cloning the repo, running `fastlane install_plugins` and `bundle exec fastlane test`. 

Here's some usage scenarios:

```ruby
# Modify Info.plist
facelift(
  ipa: "example/Example.ipa",

  iconset: "example/Blue.appiconset",

  # Set a hash of plist values
  plist_values: {
    ":CustomApplicationKey" => "Replaced!"
  },

  # Run a list of PlistBuddy commands
  plist_commands: [
    "Delete :DebugApplicationKey"
  ]
)

# Modify a different plist
facelift(
  ipa: "example/Example.ipa",
  plist_file: "GoogleService-Info.plist",
  
  plist_values: {
    ":TRACKING_ID" => "UA-22222222-22"
  }
)
```

## Run tests for this plugin

To run both the tests, and code style validation, run

```
rake
```

To automatically fix many of the styling issues, use 
```
rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/PluginsTroubleshooting.md) doc in the main `fastlane` repo.

## Using `fastlane` Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Plugins.md).

## About `fastlane`

`fastlane` is the easiest way to automate building and releasing your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
