# frozen_string_literal: true

require 'logger'
require 'socket'
require 'zeitwerk'
require 'async'
require 'openssl'
require 'base64'

require_relative 'rswim/version'

class MyInflector < Zeitwerk::Inflector
  def camelize(basename, _abspath)
    case basename
    when 'rswim' then 'RSwim'
    when 'udp' then 'UDP'
    when 'io_loop' then 'IOLoop'
    else super
    end
  end
end

loader = Zeitwerk::Loader.for_gem
loader.inflector = MyInflector.new
# version.rb defines RSwim::VERSION, not the RSwim::Version the loader would
# infer from the filename, so it is required above and left out of the loader.
loader.ignore("#{__dir__}/rswim/version.rb")
loader.setup

module RSwim
  K = 3

  # Protocol time, millis
  T_MS = 30_000

  # Roundtrip time, millis
  R_MS = 10_000

  class << self
    attr_accessor :encrypted, :shared_secret

    def validate_config!
      validate_shared_secret! if @encrypted
      true
    end

    def validate_shared_secret!
      raise Error, 'Encrypted mode was set, but no shared secret configured' if @shared_secret.nil?
      raise Error, 'Shared secret too short' if @shared_secret.length < 8
    end
  end

  class Error < StandardError; end
end
