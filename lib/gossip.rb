# frozen_string_literal: true
require "logger"
require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.setup # ready!

module Gossip
  K = 3

  # Protocol time, millis
  T_MS = 30_000

  # Roundtrip time, millis
  R_MS = 10_000

  class Error < StandardError; end
  # Your code goes here...
end
