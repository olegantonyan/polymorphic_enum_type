# frozen_string_literal: true

require_relative "lib/polymorphic_enum_type/version"

Gem::Specification.new do |spec|
  spec.name = "polymorphic_enum_type"
  spec.version = PolymorphicEnumType::VERSION
  spec.authors = ["Oleg Antonyan"]
  spec.email = ["oleg.b.antonyan@gmail.com"]

  spec.summary = "Allows integer database field for polymorphic association type instead of string via enum."
  spec.description = "Does the same as https://github.com/clio/polymorphic_integer_type but without monkey-patching, using ActiveRecord::Enum instead."
  spec.homepage = "https://github.com/olegantonyan/polymorphic_enum_type"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ">= 6"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "sqlite3"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
