# frozen_string_literal: true

module Gossip
  class ProtocolState
    def initialize(t_ms, r_ms, seed_member_ids)
      @t_ms = t_ms
      @r_ms = r_ms
      @member_pool = MemberPool.new(seed_member_ids)
      @t = @r = 1
    end

    def advance(input_messages, elapsed_seconds)
      @t += elapsed_seconds * 1000
      @t = 0 if @t >= @t_ms

      @r += elapsed_seconds * 1000
      @r = 0 if @r >= @r_ms

      input_messages.each do |message|
        raise 'message must be of type Message::Inbound' unless message.is_a? Message::Inbound

        update_member(message)
      end

      @member_pool.update_members(elapsed_seconds)

      output_messages = @member_pool.prepare_output

      @member_pool.ping_random_healthy_member if @t == 0
      @member_pool.status_report if @r == 0

      output_messages
    end

    private

    def logger
      @_logger ||= Logger.new(self.class, STDERR)
    end

    def update_member(message)
      @member_pool.update_member(message)
    rescue StandardError => e
      logger.error(e)
    end
  end
end
