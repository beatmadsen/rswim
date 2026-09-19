# frozen_string_literal: true

require 'open3'

# These run in a fresh process that only requires the library. Inside the test
# process bundler has already evaluated the gemspec, which requires
# rswim/version as a side effect, so RSwim::VERSION looks reachable here whether
# or not requiring the gem actually defines it.
RSpec.describe 'requiring rswim on its own' do
  it 'exposes the version of the loaded gem' do
    expect(in_fresh_process('print RSwim::VERSION')).to match(/\A\d+\.\d+\.\d+\z/)
  end

  it 'can load every file the loader manages' do
    expect(in_fresh_process('Zeitwerk::Loader.eager_load_all; print "ok"')).to eq('ok')
  end

  def in_fresh_process(source)
    stdout, stderr, status = Open3.capture3(
      { 'RUBYOPT' => nil, 'BUNDLER_SETUP' => nil, 'BUNDLE_BIN_PATH' => nil, 'BUNDLE_GEMFILE' => nil },
      RbConfig.ruby, '-I', File.expand_path('../lib', __dir__), '-e', "require 'rswim'; #{source}"
    )
    raise "loading rswim failed: #{stderr}" unless status.success?

    stdout
  end
end
