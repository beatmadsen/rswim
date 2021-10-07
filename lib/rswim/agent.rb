# frozen_string_literal: true

module RSwim
  module Agent
    # Non-blocking agent that is explicitly advanced
    class PushBased
      def initialize(node_member_id, seed_member_ids, t_ms, r_ms)
        @state = new_protocol_state(node_member_id, seed_member_ids, t_ms, r_ms)
      end

      def subscribe(&block)
        @state.subscribe(&block)
      end

      def append_custom_state(key, value)
        @state.append_custom_state(key, value)
      end

      def run
        @t0 = monotonic_seconds
      end

      def advance(messages)
        raise 'not running' if @t0.nil?

        t1 = monotonic_seconds
        elapsed_seconds = t1 - @t0
        @t0 = t1
        @state.advance(messages, elapsed_seconds)
      end

      protected

      def new_protocol_state(node_member_id, seed_member_ids, t_ms, r_ms)
        ProtocolState.new(node_member_id, seed_member_ids, t_ms, r_ms)
      end

      private

      def monotonic_seconds
        Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end
    end

    # Blocking agent that pops messages from pipe, processes them and pauses before repeating
    class PullBased
      def initialize(pipe, node_member_id, seed_member_ids, t_ms, r_ms)
        @pipe = pipe
        @state = new_protocol_state(node_member_id, seed_member_ids, t_ms, r_ms)
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

      def append_custom_state(key, value)
        @state.append_custom_state(key, value)
      end

      protected

      def new_protocol_state(node_member_id, seed_member_ids, t_ms, r_ms)
        ProtocolState.new(node_member_id, seed_member_ids, t_ms, r_ms)
      end

      def pause
        raise 'implement this in a subclass'
      end

      def monotonic_seconds
        Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end
    end

    class SleepBased < PullBased
      def initialize(pipe, node_member_id, seed_member_ids, t_ms, r_ms, sleep_time_seconds = 0.1)
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

    class FiberBased < PullBased
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
