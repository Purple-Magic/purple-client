# frozen_string_literal: true

require_relative "lib/purple/client/version"

Gem::Specification.new do |spec|
  spec.name = "purple-client"
  spec.version = Purple::Client::VERSION
  spec.authors = ["Pavel Kalashnikov"]
  spec.email = ["kalashnikovisme@gmail.com"]

  spec.summary = "Build API wrappers faster"
  spec.description = "Build API wrappers faster"
  spec.homepage = "https://github.com/purple-magic/purple-client"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/Purple-Magic/purple-client/releases"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'dry-initializer'
  spec.add_dependency 'activesupport'
  spec.add_dependency 'faraday'
end
