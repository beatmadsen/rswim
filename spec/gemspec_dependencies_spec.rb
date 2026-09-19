# frozen_string_literal: true

require 'bundled_gems'

# Ruby keeps moving parts of the standard library out into bundled gems. A gem
# that requires one without declaring it loads on the maintainer's machine, where
# the gem happens to be installed, and fails for everyone else.
RSpec.describe 'gemspec dependencies' do
  let(:spec) { Gem::Specification.load(File.expand_path('../rswim.gemspec', __dir__)) }

  it 'declares every bundled gem the library requires' do
    expect(required_bundled_gems - spec.dependencies.map(&:name)).to be_empty
  end

  def required_bundled_gems
    Dir.glob(File.expand_path('../lib/**/*.rb', __dir__))
       .flat_map { |file| File.read(file).scan(/^\s*require ['"]([a-z0-9_\/-]+)['"]/).flatten }
       .map { |name| name.split('/').first }
       .uniq
       .select { |name| Gem::BUNDLED_GEMS::SINCE.key?(name) }
  end
end
