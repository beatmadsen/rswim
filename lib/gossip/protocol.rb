# frozen_string_literal: true

module Gossip
  class Protocol
    def initialize(pipe)
      @pipe = pipe
      @member_pool = MemberPool.new
    end

    def run
      raise if T_MS % 10 > 0
      n = 0
      loop do
        delta_seconds = 0.010
        n += 10 # add 10 millis

        input = @pipe.receive
        input.each { |line| update_member(line) }

        @member_pool.update_members(delta_seconds)

        output = @member_pool.prepare_output
        output.each { |ary| @pipe.send(ary) }

        @member_pool.ping_random_healthy_member if n % T_MS == 0
        @member_pool.status_report if n % R_MS == 0

        sleep delta_seconds
      end
    end

    private

    def update_member(line)
      @member_pool.update_member(line)
    rescue StandardError => e
      puts e.inspect
    end
  end
end
