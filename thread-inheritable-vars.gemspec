require_relative "version"

Gem::Specification.new do |spec|
  spec.name = "inheritable-thread-vars"
  spec.version = InheritableThreadVarsVersion::VERSION
  spec.authors = ["Miles Georgi"]
  spec.email = ["azimux@gmail.com"]

  spec.summary = "Implements thread variables that default to the parent thread's value"
  spec.homepage = "https://github.com/foobara/inheritable-thread-vars"
  spec.license = "Apache-2.0 OR MIT"
  spec.required_ruby_version = InheritableThreadVarsVersion::MINIMUM_RUBY_VERSION

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir[
    "lib/**/*",
    "LICENSE*.txt",
    "README.md",
    "CHANGELOG.md"
  ]

  spec.require_paths = ["lib"]
  spec.metadata["rubygems_mfa_required"] = "true"
end
