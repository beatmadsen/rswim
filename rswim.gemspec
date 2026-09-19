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
  spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/issues"
  spec.metadata["documentation_uri"] = "#{spec.homepage}#readme"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  # Only what a user of the gem needs. Uses IO.popen with a chdir argument
  # rather than Dir.chdir, which is process-wide and cannot be nested.
  not_packaged_prefixes = %w[bin/ test/ spec/ features/ log/ tmp/ .].freeze
  not_packaged = /\A(Gemfile|Gemfile\.lock|Rakefile|Guardfile)\z/

  gemspec_name = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec_name) || f.start_with?(*not_packaged_prefixes) || f.match?(not_packaged)
    end
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 3.3'
  
  # base64 and logger left the standard library and became bundled gems in Ruby
  # 3.4 and 4.0. Requiring one without declaring it works only where it happens
  # to be installed already.
  spec.add_dependency 'base64', '~> 0.2'
  spec.add_dependency 'logger', '~> 1.6'
  spec.add_dependency 'zeitwerk', '~> 2.2'
  spec.add_dependency 'slop', '~> 4.9'
  spec.add_dependency 'async', '~> 2.0'
  
  spec.add_development_dependency "bundler", ">= 2.2.10"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'guard-rspec', '~> 4.7'
  spec.add_development_dependency 'fuubar', '~> 2.5'
  spec.add_development_dependency 'byebug'
end
