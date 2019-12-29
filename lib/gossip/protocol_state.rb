# frozen_string_literal: true

module Gossip
  class ProtocolState
    def initialize(pipe, t_ms, r_ms)
      @pipe = pipe
      @t_ms = t_ms
      @r_ms = r_ms
      @member_pool = MemberPool.new
      @t = @r = 1
    end

    def advance(elapsed_seconds)
      @t += elapsed_seconds * 1000
      @t = 0 if @t >= @t_ms

      @r += elapsed_seconds * 1000
      @r = 0 if @r >= @r_ms

      input = @pipe.inbound
      input.each { |line| update_member(line) }

      @member_pool.update_members(elapsed_seconds)

      output = @member_pool.prepare_output
      output.each { |ary| @pipe.send(ary) }

      @member_pool.ping_random_healthy_member if @t == 0
      @member_pool.status_report if @r == 0
    end

    private

    def logger
      @_logger ||= Logger.new(self.class, STDERR)
    end

    def update_member(line)
      @member_pool.update_member(line)
    rescue StandardError => e
      logger.error(e)
    end
  end
end
