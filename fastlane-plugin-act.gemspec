# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/act/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-act'
  spec.version       = Fastlane::Act::VERSION
  spec.author        = %q{Richard Szalay}
  spec.email         = %q{richard@richardszalay.com}

  spec.summary       = %q{Applies changes to plists and app icons inside a compiled IPA or xcarchive}
  spec.homepage      = "https://github.com/richardszalay/fastlane-plugin-act"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  # spec.add_dependency 'your-dependency', '~> 1.0.0'

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'fastlane', '>= 1.111.0'
end
