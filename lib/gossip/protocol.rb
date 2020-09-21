# frozen_string_literal: true

module Gossip
  module Protocol
    class Base
      def initialize(pipe, t_ms, r_ms)
        @pipe = pipe
        @state = ProtocolState.new(t_ms, r_ms)
      end

      def run
        loop do
          elapsed_seconds = pause
          output_messages = @state.advance(@pipe.inbound, elapsed_seconds)
          output_messages.each { |message| @pipe.send(message) }
        end
      end

      protected

      def pause
        raise 'implement this in a subclass'
      end

      def monotonic_seconds
        Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end
    end

    class SleepBased < Base
      def initialize(pipe, sleep_time_seconds = 0.1, t_ms = T_MS, r_ms = R_MS)
        super(pipe, t_ms, r_ms)
        @sleep_time_seconds = sleep_time_seconds
      end

      protected

      def pause
        t = monotonic_seconds
        sleep @sleep_time_seconds
        t′ = monotonic_seconds
        t′ - t
      end
    end

    class FiberBased < Base
      def run
        @f = Fiber.new { super }
      end

      def resume
        @f.resume
      end

      protected

      def pause
        t = monotonic_seconds
        Fiber.yield
        t′ = monotonic_seconds
        t′ - t
      end
    end
  end
end
