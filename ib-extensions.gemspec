require_relative 'lib/ib/extensions/version'

Gem::Specification.new do |spec|
  spec.name          = "ib-extensions"
  spec.version       = IB::Extensions::VERSION
  spec.authors       = ["Hartmut Bischoff"]
  spec.email         = ["topofocus@gmail.com"]

  spec.summary       = %q{Part of IB-Ruby. Tools to to access the tws-api comfortably.}
  spec.homepage      = "https://ib-ruby.github.io/ib-doc/"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.6.0")

#  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.cm/ib-ruby/ib-extensions"
  spec.metadata["changelog_uri"] = "https://github.cm/ib-ruby/ib-extensions/changelog.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    Dir.glob("**/*", File::FNM_DOTMATCH).reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]


	spec.add_dependency "ox"
  spec.add_dependency "ib-api", "~> 972.4"
	spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'rspec-collection_matchers'
  spec.add_development_dependency 'rspec-its' 

  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
end
