# frozen_string_literal: true

module Gossip
  class ProtocolState
    def initialize(node_member_id, seed_member_ids, t_ms, r_ms)
      @t_ms = t_ms
      @r_ms = r_ms
      @member_pool = MemberPool.new(node_member_id, seed_member_ids)
      @node_member_id = node_member_id
      @t = @r = 1
    end

    def advance(input_messages, elapsed_seconds)
      @t += elapsed_seconds * 1000
      @t = 0 if @t >= @t_ms

      @r += elapsed_seconds * 1000
      @r = 0 if @r >= @r_ms

      input_messages.each do |message|
        raise 'message must be of type Message' unless message.is_a? Message

        update_member(message)
      end

      @member_pool.update_members(elapsed_seconds)
      output_messages = @member_pool.prepare_output

      # TODO: more deterministic steady state mechanism,
      # e.g. output_messages = @member_pool.next_steady_state(elapsed_seconds)
      # using a flag set by member state
      3.times do
        @member_pool.update_members(0)
        output_messages.concat(@member_pool.prepare_output)
      end

      @member_pool.send_ping_to_random_healthy_member if @t == 0

      3.times do
        @member_pool.update_members(0)
        output_messages.concat(@member_pool.prepare_output)
      end

      @member_pool.status_report if @r == 0

      output_messages
    end

    private

    def logger
      @_logger ||= Logger.new(self.class, STDERR)
    end

    def update_member(message)
      @member_pool.update_member(message)
    # rescue StandardError => e
    #   logger.error(e)
    end
  end
end
