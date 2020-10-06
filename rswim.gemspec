lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rswim/version"

Gem::Specification.new do |spec|
  spec.name          = "rswim"
  spec.version       = RSwim::VERSION
  spec.authors       = ["Erik Madsen"]
  spec.email         = ["beatmadsen@gmail.com"]

  spec.summary       = %q{Ruby implementation of the SWIM gossip protocol}
  spec.description   = %q{RSwim is a Ruby implementation of the SWIM gossip protocol, a mechanism for discovering new peers and getting updates about liveness of existing peers in a network.}
  spec.homepage      = "https://github.com/beatmadsen/rswim"
  spec.license       = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/beatmadsen/rswim"
  spec.metadata["changelog_uri"] = "https://github.com/beatmadsen/rswim/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'zeitwerk', '~> 2.2'

  spec.add_development_dependency "bundler", "~> 2.1.4"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'guard-rspec', '~> 4.7'
  spec.add_development_dependency 'fuubar', '~> 2.5'
  spec.add_development_dependency 'byebug'
end
