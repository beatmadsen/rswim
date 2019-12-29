# frozen_string_literal: true

module Gossip
  class Protocol
    def initialize(pipe, t_ms = T_MS, r_ms = R_MS)
      @state = ProtocolState.new(pipe, t_ms, r_ms)
    end

    def run
      t = monotonic_seconds
      loop do
        t_dash = monotonic_seconds
        delta_seconds = t_dash - t
        t = t_dash

        @state.advance(delta_seconds)

        sleep 0.1
      end
    end

    private

    def monotonic_seconds
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end
  end
end
