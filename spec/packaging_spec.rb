# frozen_string_literal: true

# The file list is built by pattern, so a new top-level file joins the published
# gem unless someone remembers to exclude it.
RSpec.describe 'the published package' do
  let(:spec) { Gem::Specification.load(File.expand_path('../rswim.gemspec', __dir__)) }

  it 'carries the library and its documents' do
    expect(%w[README.md LICENSE.txt CHANGELOG.md lib/rswim.rb] - spec.files).to be_empty
  end

  it 'leaves out the development scaffolding' do
    expect(spec.files.grep(%r{\A(bin/|spec/|log/|tmp/|\.)|\A(Gemfile|Rakefile|Guardfile)})).to be_empty
  end

  it 'requires multi-factor auth to publish' do
    expect(spec.metadata['rubygems_mfa_required']).to eq('true')
  end
end
