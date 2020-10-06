# frozen_string_literal: true

module RSwim
  module Agent
    class Base
      def initialize(pipe, node_member_id, seed_member_ids, t_ms, r_ms)
        @pipe = pipe
        @state = ProtocolState.new(node_member_id, seed_member_ids, t_ms, r_ms)
      end

      def subscribe(&block)
        @state.subscribe(&block)
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
      def initialize(pipe, node_member_id, seed_member_ids, sleep_time_seconds = 0.1, t_ms = T_MS, r_ms = R_MS)
        super(pipe, node_member_id, seed_member_ids, t_ms, r_ms)
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
