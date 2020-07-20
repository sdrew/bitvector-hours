
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "bitvector/hours/version"

Gem::Specification.new do |spec|
  spec.name          = "bitvector-hours"
  spec.version       = BitVector::Hours::VERSION
  spec.authors       = ["Stephen Drew"]
  spec.email         = ["rubygems@sdrew.me"]

  spec.summary       = %q{Bitvector Hours}
  spec.description   = %q{Bitvector Hours}
  spec.homepage      = "https://github.com/sdrew/bitvector-hours"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = spec.homepage
    spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/issues"
    spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/master/CHANGELOG.md"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(\.github|test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", ">= 4.1.0"
  spec.add_dependency "bitvector", "~> 1.0.0"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "codecov", "~> 0.2.2"
end
