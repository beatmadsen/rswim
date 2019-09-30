# frozen_string_literal: true

require 'gossip/version'
require 'gossip/pipe'
require 'gossip/member'
require 'gossip/member_state'
require 'gossip/member_pool'
require 'gossip/status_report'
require 'gossip/protocol'
require 'gossip/ack_responder'

module Gossip
  K = 3

  # Protocol time, millis
  T_MS = 30_000

  # Roundtrip time, millis
  R_MS = 10_000

  class Error < StandardError; end
  # Your code goes here...
end
