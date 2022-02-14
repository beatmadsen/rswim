# frozen_string_literal: true

require 'logger'
require 'socket'
require 'zeitwerk'
require 'async'
require 'openssl'
require 'base64'

cipher = OpenSSL::Cipher::AES256.new :CBC
cipher.encrypt
iv = cipher.random_iv
cipher.key = key = Digest::SHA256.digest 'SecretPassword'
cipher_text = cipher.update('This is a secret message') + cipher.final

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
